module DocumentsHelper

  def to_percent(number)
    sprintf("%.2f%",number)
  end

  def pie_image(hash)
    value_array = []
    hash.each do |key,hash|
      array = [key,sprintf("%0.2f",hash[:percent]).to_f]
      value_array << array
    end

    %`
      <script type='text/javascript'>
      var chart;
      jQuery(document).ready(function() {
         chart = new Highcharts.Chart({
            chart: {
               renderTo: 'container',
               margin: [20, 50, 0, 0],
               height: 300,
               width: 500
            },
            title: {
               text: '操作百分比'
            },
            plotArea: {
               shadow: null,
               borderWidth: null,
               backgroundColor: null
            },
            tooltip: {
               formatter: function() {
                  return '<b>'+ this.point.name +'</b>: '+ this.y +' %';
               }
            },
            plotOptions: {
               pie: {
                  allowPointSelect: true,
                  cursor: 'pointer',
                  dataLabels: {
                     enabled: true,
                     formatter: function() {
                        if (this.y > 5) return this.point.name;
                     },
                     color: 'white',
                     style: {
                        font: '13px Trebuchet MS, Verdana, sans-serif'
                     }
                  }
               }
            },
            legend: {
               layout: 'vertical',
               style: {
                  left: 'auto',
                  bottom: 'auto',
                  right: '50px',
                  top: '100px'
               }
            },
             series: [{
               type: 'pie',
               name: 'Browser share',
               data: #{value_array.to_json}
            }]
         });
      });
      </script>
    `
  end

end
