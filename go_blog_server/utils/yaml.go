package utils

import (
	"io/fs"
	"os"
	"server/global"

	"gopkg.in/yaml.v3"
)

// LoadYAML 从文件中读取 YAML 数据并返回字节数组
// 优先级：local-config.yaml > config.yaml
func LoadYAML() ([]byte, error) {
	// 优先读取本地配置文件（用于本地开发）
	if data, err := os.ReadFile("local-config.yaml"); err == nil {
		return data, nil
	}
	// 其次读取默认配置文件（用于生产环境或 Docker）
	return os.ReadFile("config.yaml")
}

// SaveYAML 将全局配置对象保存为 YAML 格式到文件
// 优先级：如果 local-config.yaml 存在就保存到它，否则保存到 config.yaml
func SaveYAML() error {
	byteData, err := yaml.Marshal(global.Config)
	if err != nil {
		return err
	}
	// 如果 local-config.yaml 存在，保存到本地文件
	if _, err := os.Stat("local-config.yaml"); err == nil {
		return os.WriteFile("local-config.yaml", byteData, fs.ModePerm)
	}
	// 否则保存到默认配置文件
	return os.WriteFile("config.yaml", byteData, fs.ModePerm)
}
