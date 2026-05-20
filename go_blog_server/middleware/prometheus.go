package middleware

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// 请求总数
	requestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Namespace: "go_blog",	// 指标前缀
			Name:      "http_requests_total",	// 指标名称
			Help:      "Total number of HTTP requests by method, path and status",	// 指标描述
		},
		[]string{"method", "path", "status"},	// 标签：HTTP 方法、路径和状态码
	)

	// 请求响应时间
	requestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Namespace: "go_blog",
			Name:      "http_request_duration_seconds",
			Help:      "HTTP request latency in seconds by method and path",
			Buckets:   []float64{0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10},	// 0-10ms、10-50ms、50-100ms、100-250ms、250-500ms、500ms-1s、1-2.5s、2.5-5s、5-10s、>10s
		},
		[]string{"method", "path"},
	)

	// 当前正在处理的请求数（并发）
	inFlightGauge = promauto.NewGauge(
		prometheus.GaugeOpts{
			Namespace: "go_blog",
			Name:      "http_in_flight_requests",
			Help:      "Current number of in-flight HTTP requests",
		},
	)
)

// PrometheusMetrics 返回一个 Gin 中间件，收集 HTTP 请求的 Prometheus 指标。
// 自动跳过 /metrics 路径，避免抓取自身造成干扰。
func PrometheusMetrics() gin.HandlerFunc {
	return func(c *gin.Context) {
		if c.Request.URL.Path == "/metrics" {
			c.Next()
			return
		}

		inFlightGauge.Inc()
		defer inFlightGauge.Dec()

		start := time.Now()
		path := c.FullPath()
		if path == "" {
			path = "unknown"
		}

		c.Next()

		duration := time.Since(start)
		status := strconv.Itoa(c.Writer.Status())
		requestsTotal.WithLabelValues(c.Request.Method, path, status).Inc()
		requestDuration.WithLabelValues(c.Request.Method, path).Observe(duration.Seconds())
	}
}

// PrometheusHandler，包装 promhttp.Handler()，使其适用于 Gin 框架，提供 /metrics 端点供 Prometheus 抓取指标数据。
func PrometheusHandler() gin.HandlerFunc {
	h := promhttp.Handler()
	return func(c *gin.Context) {
		// 调用 promhttp.Handler() 来处理 Gin 框架的 HTTP 请求 
		h.ServeHTTP(c.Writer, c.Request)	// h.ServeHTTP() 是 HTTP 处理器的标准方法，用来处理一个 HTTP 请求并生成响应
	}
}
