require 'json'
require 'date'

class JsonFilehandler
  
  def self.read_file(path)
    File.open(path).read
  end

  def self.write_file(path, res)

    File.open(path, "w+") do |f|
      f.write("[\n")
      res.each_with_index do |click, idx|
        if idx != res.size-1
         result = '{' + click.map { |k, v| "#{k.to_json}:#{v.to_json}" }.join(', ') + "},\n"
        else
          result = '{' + click.map { |k, v| "#{k.to_json}:#{v.to_json}" }.join(', ') + "}\n"
        end
        f.write(result)
      end
      f.write("]")
    end
  end
  
end

class Parser
  
  def self.to_json(file_data)
    JSON.parse(file_data)
  end

  def self.collect_valid_clicks(click_data)
    click_freq = Hash.new(0)
    click_data.each { |ele| click_freq[ele['ip']] += 1 }
    # Remove all IPs with clicks greater than 10
    click_freq.each { |k, v| if v >= 10 ; click_freq.delete(k) end}
    click_ips = click_freq.keys
    click_data.select { |ele| click_ips.include?(ele['ip'])}
  end

  def self.find_period(timestamp)
    DateTime.parse(timestamp).hour
  end

  def self.clicks_per_period(valid_clicks)
    ip_amt_per_period = {}
    ip_timestamp_per_period = {}
    valid_clicks.each do |click|
      period = DateTime.parse(click["timestamp"]).hour
      if ip_amt_per_period.key?(click["ip"])
        if ip_amt_per_period[click["ip"]].key?(period) && ip_amt_per_period[click["ip"]][period] < click["amount"]
          ip_amt_per_period[click["ip"]][period] = click["amount"]
          ip_timestamp_per_period[click["ip"]].merge!({period => click["timestamp"]})
        elsif ip_amt_per_period[click["ip"]].key?(period) && ip_amt_per_period[click["ip"]][period] > click["amount"]
          next
        elsif ip_amt_per_period[click["ip"]].key?(period) && ip_amt_per_period[click["ip"]][period] == click["amount"]
          ip_timestamp_per_period[click["ip"]][period] = DateTime.parse(click["timestamp"]) < DateTime.parse(ip_timestamp_per_period[click["ip"]][period]) ?
           click["timestamp"] : ip_timestamp_per_period[click["ip"]][period]
        else
          ip_amt_per_period[click["ip"]].merge!({period => click["amount"]})
          ip_timestamp_per_period[click["ip"]].merge!({period => click["timestamp"]})
        end
        
      else 
        ip_amt_per_period[click["ip"]] = {} 
        ip_timestamp_per_period[click["ip"]] = {}
        ip_amt_per_period[click["ip"]][period] = click["amount"]
        ip_timestamp_per_period[click["ip"]][period] = click["timestamp"]
      end
    end
    return ip_amt_per_period, ip_timestamp_per_period
  end

  def self.form_output_array(ip_amt_per_period, ip_timestamp_per_period)
    res = []
    ip_amt_per_period.each do |k,v| 
      v.each {|period, value| res.push({"ip" => k, "timestamp" => ip_timestamp_per_period[k][period] , "amount" => value})}
    end
    res
  end
end


class ClickHandler

  def self.main
    all_clicks = []
    file_data = JsonFilehandler.read_file("clicks.json")
    click_data = Parser.to_json(file_data)
    valid_clicks = Parser.collect_valid_clicks(click_data)
    ip_amt_per_period, ip_timestamp_per_period = Parser.clicks_per_period(valid_clicks)
    res = Parser.form_output_array(ip_amt_per_period, ip_timestamp_per_period)
    JsonFilehandler.write_file("result.json", res)
  end
end

ClickHandler.main