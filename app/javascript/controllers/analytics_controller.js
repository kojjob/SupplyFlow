import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

/**
 * Analytics Controller
 * Handles rendering and updating of analytics charts on the dashboard
 */
export default class extends Controller {
  static targets = [
    "inventoryTrendChart", 
    "transactionTypeChart", 
    "inventoryLocationChart",
    "inventoryStatusChart", 
    "categoryValueChart"
  ]

  connect() {
    this.initializeCharts()
  }

  // Initialize all charts when controller connects
  initializeCharts() {
    this.renderInventoryTrendChart()
    this.renderTransactionTypeChart()
    this.renderInventoryLocationChart()
    this.renderInventoryStatusChart()
    this.renderCategoryValueChart()
    
    // Apply responsive behavior
    this.setupResponsiveCharts()
  }
  
  // Setup responsive behavior for charts
  setupResponsiveCharts() {
    window.addEventListener('resize', () => {
      this.charts.forEach(chart => {
        if (chart) chart.render()
      })
    })
  }
  
  // Store chart instances for reference
  charts = []

  // Inventory trend chart (line chart)
  renderInventoryTrendChart() {
    if (!this.hasInventoryTrendChartTarget) return
    
    const chartData = JSON.parse(this.inventoryTrendChartTarget.dataset.chart)
    
    const options = {
      series: [{
        name: 'Total Inventory',
        data: chartData.values
      }],
      chart: {
        height: 350,
        type: 'area',
        toolbar: {
          show: false
        },
        fontFamily: 'Poppins, sans-serif',
        animations: {
          enabled: true,
          easing: 'easeinout',
          speed: 800
        }
      },
      colors: ['#3b82f6'],
      fill: {
        type: 'gradient',
        gradient: {
          shadeIntensity: 1,
          opacityFrom: 0.7,
          opacityTo: 0.2,
          stops: [0, 90, 100]
        }
      },
      dataLabels: {
        enabled: false
      },
      stroke: {
        curve: 'smooth',
        width: 3
      },
      grid: {
        borderColor: '#e5e7eb',
        strokeDashArray: 4,
        padding: {
          top: 0,
          right: 0,
          bottom: 0,
          left: 10
        }
      },
      xaxis: {
        categories: chartData.dates,
        labels: {
          style: {
            fontSize: '12px',
            fontFamily: 'Poppins, sans-serif'
          }
        },
        axisBorder: {
          show: false
        },
        axisTicks: {
          show: false
        }
      },
      yaxis: {
        labels: {
          formatter: function (value) {
            return Math.round(value)
          },
          style: {
            fontSize: '12px',
            fontFamily: 'Poppins, sans-serif'
          }
        }
      },
      tooltip: {
        theme: 'light',
        x: {
          format: 'dd MMM'
        }
      },
      legend: {
        position: 'top',
        horizontalAlign: 'right'
      }
    }

    const chart = new ApexCharts(this.inventoryTrendChartTarget, options)
    chart.render()
    this.charts.push(chart)
  }

  // Transaction type chart (pie chart)
  renderTransactionTypeChart() {
    if (!this.hasTransactionTypeChartTarget) return
    
    const chartData = JSON.parse(this.transactionTypeChartTarget.dataset.chart)
    const labels = Object.keys(chartData)
    const values = Object.values(chartData)
    
    const options = {
      series: values,
      chart: {
        width: 380,
        type: 'pie',
        fontFamily: 'Poppins, sans-serif'
      },
      colors: ['#3b82f6', '#8b5cf6', '#10b981', '#f59e0b', '#ef4444', '#6366f1'],
      labels: labels,
      responsive: [{
        breakpoint: 480,
        options: {
          chart: {
            width: 300
          },
          legend: {
            position: 'bottom'
          }
        }
      }],
      legend: {
        position: 'bottom',
        fontFamily: 'Poppins, sans-serif'
      },
      dataLabels: {
        formatter: function (val, opts) {
          return opts.w.config.series[opts.seriesIndex]
        }
      },
      tooltip: {
        y: {
          formatter: function(value) {
            return value + ' transactions'
          }
        }
      }
    }

    const chart = new ApexCharts(this.transactionTypeChartTarget, options)
    chart.render()
    this.charts.push(chart)
  }

  // Inventory by location (donut chart)
  renderInventoryLocationChart() {
    if (!this.hasInventoryLocationChartTarget) return
    
    const chartData = JSON.parse(this.inventoryLocationChartTarget.dataset.chart)
    const labels = chartData.map(item => item.name)
    const values = chartData.map(item => item.value)
    
    const options = {
      series: values,
      chart: {
        width: 380,
        type: 'donut',
        fontFamily: 'Poppins, sans-serif'
      },
      colors: ['#3b82f6', '#8b5cf6', '#10b981', '#f59e0b', '#ef4444'],
      labels: labels,
      dataLabels: {
        enabled: true,
        formatter: function (val) {
          return Math.round(val) + '%'
        }
      },
      responsive: [{
        breakpoint: 480,
        options: {
          chart: {
            width: 300
          },
          legend: {
            position: 'bottom'
          }
        }
      }],
      legend: {
        position: 'bottom',
        fontFamily: 'Poppins, sans-serif'
      },
      tooltip: {
        y: {
          formatter: function(value) {
            return value + ' items'
          }
        }
      }
    }

    const chart = new ApexCharts(this.inventoryLocationChartTarget, options)
    chart.render()
    this.charts.push(chart)
  }

  // Inventory status chart (radial bar)
  renderInventoryStatusChart() {
    if (!this.hasInventoryStatusChartTarget) return
    
    const chartData = JSON.parse(this.inventoryStatusChartTarget.dataset.chart)
    const statuses = Object.keys(chartData)
    const counts = Object.values(chartData)
    const total = counts.reduce((a, b) => a + b, 0)
    
    // Calculate percentages
    const percentages = counts.map(count => Math.round(count / total * 100))
    
    // Get colors based on status
    const colors = statuses.map(status => {
      switch(status) {
        case 'available': return '#10b981'
        case 'reserved': return '#f59e0b'
        case 'damaged': return '#ef4444'
        case 'expired': return '#6b7280'
        case 'quarantined': return '#8b5cf6'
        default: return '#3b82f6'
      }
    })
    
    const options = {
      series: percentages,
      chart: {
        height: 350,
        type: 'radialBar',
        fontFamily: 'Poppins, sans-serif'
      },
      colors: colors,
      plotOptions: {
        radialBar: {
          dataLabels: {
            name: {
              fontSize: '22px',
              fontFamily: 'Poppins, sans-serif'
            },
            value: {
              fontSize: '16px',
              fontFamily: 'Poppins, sans-serif',
              formatter: function(val) {
                return val + '%'
              }
            },
            total: {
              show: true,
              label: 'Total',
              formatter: function() {
                return total
              }
            }
          },
          track: {
            background: '#f3f4f6',
            strokeWidth: '97%',
            margin: 5
          }
        }
      },
      labels: statuses.map(s => s.charAt(0).toUpperCase() + s.slice(1)),
      stroke: {
        lineCap: 'round'
      }
    }

    const chart = new ApexCharts(this.inventoryStatusChartTarget, options)
    chart.render()
    this.charts.push(chart)
  }

  // Inventory value by category (bar chart)
  renderCategoryValueChart() {
    if (!this.hasCategoryValueChartTarget) return
    
    const chartData = JSON.parse(this.categoryValueChartTarget.dataset.chart)
    const categories = chartData.map(item => item.category)
    const values = chartData.map(item => item.value)
    
    const options = {
      series: [{
        name: 'Value',
        data: values
      }],
      chart: {
        type: 'bar',
        height: 350,
        fontFamily: 'Poppins, sans-serif',
        toolbar: {
          show: false
        }
      },
      colors: ['#8b5cf6'],
      plotOptions: {
        bar: {
          horizontal: true,
          borderRadius: 4,
          dataLabels: {
            position: 'top'
          }
        }
      },
      dataLabels: {
        enabled: true,
        formatter: function (val) {
          return '₵' + val.toFixed(2)
        },
        offsetX: 30,
        style: {
          fontSize: '12px',
          colors: ['#304758']
        }
      },
      stroke: {
        show: true,
        width: 2,
        colors: ['transparent']
      },
      xaxis: {
        categories: categories,
        labels: {
          formatter: function(val) {
            return '₵' + Math.round(val)
          }
        }
      },
      yaxis: {
        title: {
          text: 'Category'
        }
      },
      fill: {
        opacity: 1,
        type: 'gradient',
        gradient: {
          shade: 'light',
          type: 'horizontal',
          shadeIntensity: 0.25,
          gradientToColors: ['#6366f1'],
          inverseColors: true,
          opacityFrom: 1,
          opacityTo: 0.85
        }
      },
      tooltip: {
        y: {
          formatter: function (val) {
            return '₵' + val.toFixed(2)
          }
        }
      },
      legend: {
        position: 'top',
        horizontalAlign: 'right'
      }
    }

    const chart = new ApexCharts(this.categoryValueChartTarget, options)
    chart.render()
    this.charts.push(chart)
  }
  
  // Handle filtering by dates
  filterDateRange(event) {
    const range = event.currentTarget.dataset.range
    
    // Update charts based on range
    // This would typically fetch new data from the server via AJAX
    console.log('Filtering by range:', range)
  }
  
  // Cleanup charts when controller disconnects
  disconnect() {
    this.charts.forEach(chart => {
      if (chart) chart.destroy()
    })
    this.charts = []
  }
}