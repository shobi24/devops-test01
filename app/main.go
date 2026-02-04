package main

import (
	"fmt"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// สร้าง metric: นับจำนวน HTTP requests
var httpRequests = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "myapp_http_requests_total",
		Help: "Total number of HTTP requests",
	},
	[]string{"method", "endpoint"},
)

// สร้าง metric: วัดเวลาที่ใช้ในการตอบสนอง
var httpDuration = prometheus.NewHistogramVec(
	prometheus.HistogramOpts{
		Name:    "myapp_http_request_duration_seconds",
		Help:    "HTTP request latency",
		Buckets: prometheus.DefBuckets,
	},
	[]string{"endpoint"},
)

func main() {
	// ลงทะเบียน metrics
	prometheus.MustRegister(httpRequests)
	prometheus.MustRegister(httpDuration)

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		// เพิ่มค่าการนับ request
		httpRequests.WithLabelValues(r.Method, "/").Inc()

		// จำลองการทำงาน
		time.Sleep(100 * time.Millisecond)

		fmt.Fprintf(w, "Hello, Prometheus!")

		// บันทึกเวลาที่ใช้
		duration := time.Since(start).Seconds()
		httpDuration.WithLabelValues("/").Observe(duration)
	})

	// endpoint สำหรับ Prometheus มาเก็บ metrics
	http.Handle("/metrics", promhttp.Handler())

	fmt.Println("Server running on :8080")
	http.ListenAndServe(":8080", nil)
}
