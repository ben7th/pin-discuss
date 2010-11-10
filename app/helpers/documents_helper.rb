module DocumentsHelper

  def to_percent(number)
    sprintf("%.2f%",number)
  end

  def pie_xml(hash)
    title = "个人操作统计"
    set_str = ""
    p hash
    hash.each do |key,hash|
      name = key
      value = sprintf("%0.2f",hash[:percent]).to_f
      set_str << %`<set name="#{name}" value="#{value}"/>`
    end
    %`
      <graph caption="#{title}"  bgAlpha="0" pieBorderAlpha="50" pieRadius="120"  pieYScale='30' toolTipBgColor="#000000" baseFontColor="#999999" baseFontSize="20" showNames="1"  decimalPrecision="0" >
        #{set_str}
      </graph>
    `
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

  def document_title(document)
    title = document.title

    match_data = title.match(/<bundle>.*<\/bundle>(.*)/)
    if match_data
      bundle_title = match_data[1]
      bundle_title = "无标题" if bundle_title.blank?
      title = "bundle(#{bundle_title})"
    end
    title
  end

end
