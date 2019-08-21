require 'csv'
require 'nokogiri'
require 'open-uri'
page=("https://www.petsonic.com/snacks-huesos-para-perros/")


doc=Nokogiri::HTML(open(page))

page=1
max_positions=doc.xpath('//span[@class="heading-counter"]').text.gsub(' productos','')
max_per_page=doc.xpath('//ul[@id="product_list"]/li').count
last_page=(max_positions.to_f/max_per_page.to_f).round

prod=[]

while page <= last_page

  unless page>1
    pagination=("https://www.petsonic.com/snacks-huesos-para-perros/")
    puts pagination
  else
    pagination=("https://www.petsonic.com/snacks-huesos-para-perros/?p=#{page}")
    puts pagination
  end
  doc2=Nokogiri::HTML(open(pagination))

  links=doc2.xpath('//a[@class="product-name"]/@href')
  links.each do |url|
    doc3=Nokogiri::HTML(open(url))
    name1=doc3.xpath('//p[@class="product_main_name"]')

    name1.each do |name|

position = 1

last_position=doc3.xpath('//ul[contains(@class,"attribute_radio_list")]
/li[contains(@class,"comb")]
/label[(contains(@class,"label_comb_price comb"))]
/span[contains(@class,"radio_label")]').count

    while position<=last_position

      unchecked_gr=doc3.xpath("//ul/li[#{position}]/label[not(contains(@class,'checked'))]/span[1]")
      checked_gr=doc3.xpath("//ul/li[#{position}]/label[(contains(@class,'checked'))]/span[1]")


        if unchecked_gr.at_xpath("//ul/li[#{position}]/label[not(contains(@class,'checked'))]/span[1]")

          unchecked_img=doc3.xpath("//ul[@id='thumbs_list_frame']/li[#{position}]/a[@class='fancybox replace-2x']/@href")
          if unchecked_img.at_xpath("//ul[@id='thumbs_list_frame']/li[#{position}]/a[@class='fancybox replace-2x']/@href")
            img=doc3.xpath("//ul[@id='thumbs_list_frame']/li[#{position}]/a[@class='fancybox replace-2x']/@href")
          else
            img=doc3.xpath("//ul[@id='thumbs_list_frame']/li/a[contains(@class,'shown')]/@href")
          end


          price=doc3.xpath("//ul/li[#{position}]/label[not(contains(@class,'checked'))]/span[2]").text.gsub('/u','')
          combine=[name,unchecked_gr].join(' - ')


        elsif checked_gr.at_xpath("//ul/li[#{position}]/label[(contains(@class,'checked'))]/span[1]")
          img=doc3.xpath("//ul[@id='thumbs_list_frame']/li/a[contains(@class,'shown')]/@href").text
          price=doc3.xpath("//ul/li[#{position}]/label[(contains(@class,'checked'))]/span[2]").text.gsub('/u','')
          combine=[name,checked_gr].join(' - ')
        end

  prod.push(
    name:combine,
    price:price,
    img:img
  )
  puts prod
  position +=1
  end
end
end
page +=1
end

CSV.open('Parser_TZ.csv','w',write_headers:true,headers:prod.first.keys) do|csv|
  prod.each do|product|
    csv << product.values
  end
end
