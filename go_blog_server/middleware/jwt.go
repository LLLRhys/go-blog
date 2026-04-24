package middleware

import (
	"errors"
	"server/global"
	"server/model/database"
	"server/model/request"
	"server/model/response"
	"server/service"
	"server/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

var jwtService = service.ServiceGroupApp.JwtService

func JWTAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		accessToken := utils.GetAccessToken(c)
		refreshToken := utils.GetRefreshToken(c)

		if jwtService.IsInBlacklist(refreshToken) {
			utils.ClearRefreshToken(c)
			response.NoAuth("Account logged in from another location or token is invalid", c)
			c.Abort()
			return
		}

		j := utils.NewJWT()

		claims, err := j.ParseAccessToken(accessToken)
		if err != nil {
			// 如果 Access Token 为空或过期，尝试使用 Refresh Token 刷新 Access Token
			if accessToken == "" || errors.Is(err, utils.TokenExpired) {
				refreshClaims, err := j.ParseRefreshToken(refreshToken)
				// 如果 Refresh Token 也无效或过期，清除 Refresh Token 并返回未授权响应
				if err != nil {
					utils.ClearRefreshToken(c)
					response.NoAuth("Refresh token expired or invalid", c)
					c.Abort()
					return
				}

				// RefreshToken还有效，生成新的 Access Token
				var user database.User
				if err := global.DB.Select("uuid", "role_id").Take(&user, refreshClaims.UserID).Error; err != nil {
					utils.ClearRefreshToken(c)
					response.NoAuth("The user does not exist", c)
					c.Abort()
					return
				}

				newAccessClaims := j.CreateAccessClaims(request.BaseClaims{
					UserID: refreshClaims.UserID,
					UUID:   user.UUID,
					RoleID: user.RoleID,
				})

				newAccessToken, err := j.CreateAccessToken(newAccessClaims)
				if err != nil {
					utils.ClearRefreshToken(c)
					response.NoAuth("Faild to create new access token", c)
					c.Abort()
					return
				}

				c.Header("new-access-token", newAccessToken)	// 写响应头，返回给前端
				c.Header("new-access-expires-at", strconv.FormatInt(newAccessClaims.ExpiresAt.Unix(), 10))

				c.Set("claims", &newAccessClaims)	// 写上下文 gin.Context ，给后续的处理链路使用
				c.Next()
				return
			}

			utils.ClearRefreshToken(c)
			response.NoAuth("Invalid access token", c)
			c.Abort()
			return
		}

		c.Set("claims", claims)
		c.Next()
	}
}
