package utils

import (
	"fmt"
	"math"
	"math/rand"
	"time"
)

// GenerateVerificationCode 生成一个指定长度的随机验证码
func GenerateVerificationCode(length int) string {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))  // New()生成随机数，NewSource()生成随机数源，获取当前时间的纳秒级时间戳作为随机数源
	return fmt.Sprintf("%0*d", length, r.Intn(int(math.Pow10(length))))	// Intn() 生成一个[0, n)的随机数，math.Pow10()返回10的n次方]
}
