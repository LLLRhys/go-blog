package upload

import (
	"errors"
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"server/global"
	"server/utils"
	"strings"
	"time"
)

type Local struct {
}

func (*Local) UploadImage(file *multipart.FileHeader) (string, string, error) {
	size := float64(file.Size) / float64(1024*1024)	// 计算图片大小，单位为 MB
	if size >= float64(global.Config.Upload.Size) {
		return "", "", fmt.Errorf("the image size exceeds the set size, the current size is: %.2f MB, the set size is: %d MB", size, global.Config.Upload.Size)

	}

	ext := filepath.Ext(file.Filename)	// Ext() 获取文件扩展名（包括.）
	name := strings.TrimSuffix(file.Filename, ext)	// TrimSuffix() 去掉文件名中的扩展名部分，得到纯文件名
	if _, exists := WhiteImageList[ext]; !exists {	// 是不是支持的图片类型
		return "", "", errors.New("don't upload files that aren't image types")
	}

	filename := utils.MD5V([]byte(name)) + "-" + time.Now().Format("20060102150405") + ext
	path := global.Config.Upload.Path + "/image/"

	if err := os.MkdirAll(path, os.ModePerm); err != nil {
		return "", "", err
	}

	filepath := path + filename

	out, err := os.Create(filepath)
	if err != nil {
		return "", "", err
	}
	defer out.Close()

	f, err := file.Open()
	if err != nil {
		return "", "", err
	}
	defer f.Close()

	if _, err = io.Copy(out, f); err != nil {
		return "", "", err
	}

	return "/" + filepath, filename, nil
}

func (*Local) DeleteImage(key string) error {
	path := global.Config.Upload.Path + "/image/" + key
	return os.Remove(path)
}
