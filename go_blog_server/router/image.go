package router

import (
	"server/api"

	"github.com/gin-gonic/gin"
)

type ImageRouter struct {
}

func (i *ImageRouter) InitImageRouter(Router *gin.RouterGroup) {
	imageRouter := Router.Group("image")	// 只能管理员路由

	imageApi := api.ApiGroupApp.ImageApi
	{
		imageRouter.POST("upload", imageApi.ImageUpload)
		imageRouter.DELETE("delete", imageApi.ImageDelete)
		imageRouter.GET("list", imageApi.ImageList)
	}
}
