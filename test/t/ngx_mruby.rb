##
# ngx_mruby test

def base
  'http://127.0.0.1:58080'
end

t = SimpleTest.new "ngx_mruby test"

t.assert('ngx_mruby', 'location /mruby') do
  res = HttpRequest.new.get base + '/mruby'
  t.assert_equal 'Hello ngx_mruby world!', res["body"]
end

t.assert('ngx_mruby', 'location /proxy') do
  res = HttpRequest.new.get base + '/proxy'
  t.assert_equal 'proxy test ok', res["body"]
end

t.assert('ngx_mruby', 'location /vars') do
  res = HttpRequest.new.get base + '/vars'
  t.assert_equal 'host => 127.0.0.1 foo => mruby', res["body"]
end

t.assert('ngx_mruby', 'location /redirect') do
  res = HttpRequest.new.get base + '/redirect'
  t.assert_equal 301, res.code
  t.assert_equal 'http://ngx.mruby.org', res["location"]
end

t.assert('ngx_mruby', 'location /redirect/internal') do
  res = HttpRequest.new.get base + '/redirect/internal'
  t.assert_equal 'host => 127.0.0.1 foo => mruby', res["body"]
end

t.assert('ngx_mruby', 'location /inter_var_file') do
  res = HttpRequest.new.get base + '/inter_var_file'
  t.assert_equal 'fuga => 200 hoge => 400 hoge => 800', res["body"]
end

t.assert('ngx_mruby', 'location /inter_var_inline') do
  res = HttpRequest.new.get base + '/inter_var_inline'
  t.assert_equal 'fuga => 100 hoge => 200 hoge => 400', res["body"]
end

t.assert('ngx_mruby - output filter', 'location /filter_dynamic_arg') do
  res = HttpRequest.new.get base + '/filter_dynamic_arg'
  t.assert_equal 'output filter: static', res["body"]
end

t.assert('ngx_mruby - output filter', 'location /filter_dynamic_arg?hoge=fuga') do
  res = HttpRequest.new.get base + '/filter_dynamic_arg?hoge=fuga'
  t.assert_equal 'output filter: hoge=fuga', res["body"]
end

t.assert('ngx_mruby - Nginx::Connection#{local_ip,local_port}', 'location /server_ip_port') do
  res = HttpRequest.new.get base + '/server_ip_port'
  t.assert_equal '127.0.0.1:58080', res["body"]
end

t.assert('ngx_mruby - Nginx::Connection#{remote_ip,local_port}', 'location /client_ip') do
  res = HttpRequest.new.get base + '/client_ip'
  t.assert_equal '127.0.0.1', res["body"]
end

t.assert('ngx_mruby', 'location /header') do
  res1 = HttpRequest.new.get base + '/header'
  res2 = HttpRequest.new.get base + '/header', nil, {"X-REQUEST-HEADER" => "hoge"}

  t.assert_equal "X-REQUEST-HEADER not found", res1["body"]
  t.assert_equal "nothing", res1["x-response-header"]
  t.assert_equal "X-REQUEST-HEADER found", res2["body"]
  t.assert_equal "hoge", res2["x-response-header"]
end

t.assert('ngx_mruby - mruby_add_handler', '*\.rb') do
  res = HttpRequest.new.get base + '/add_handler.rb'
  t.assert_equal 'add_handler', res["body"]
end

t.assert('ngx_mruby - all instance test', 'location /all_instance') do
  res = HttpRequest.new.get base + '/all_instance'
  t.assert_equal "OK", res["x-inst-test"]
end

t.assert('ngx_mruby', 'location /request_method') do
  res = HttpRequest.new.get base + '/request_method'
  t.assert_equal "GET", res["body"]
  res = HttpRequest.new.post base + '/request_method'
  t.assert_equal "POST", res["body"]
  res = HttpRequest.new.head base + '/request_method'
  t.assert_equal "HEAD", res["body"]
end

t.assert('ngx_mruby - Kernel.server_name', 'location /kernel_servername') do
  res = HttpRequest.new.get base + '/kernel_servername'
  t.assert_equal 'NGINX', res["body"]
end

# see below url:
# https://github.com/matsumoto-r/ngx_mruby/wiki/Class-and-Method#refs-nginx-core-variables
t.assert('ngx_mruby - Nginx::Var', 'location /nginx_var?name=name') do
  t.assert_equal '/nginx_var', HttpRequest.new.get(base + '/nginx_var?name=uri')["body"]
  t.assert_equal 'HTTP/1.0', HttpRequest.new.get(base + '/nginx_var?name=server_protocol')["body"]
  t.assert_equal 'http', HttpRequest.new.get(base + '/nginx_var?name=scheme')["body"]
  t.assert_equal '127.0.0.1', HttpRequest.new.get(base + '/nginx_var?name=remote_addr')["body"]
  t.assert_equal '58080', HttpRequest.new.get(base + '/nginx_var?name=server_port')["body"]
  t.assert_equal '127.0.0.1', HttpRequest.new.get(base + '/nginx_var?name=server_addr')["body"]
  t.assert_equal 'GET /nginx_var?name=request HTTP/1.0', HttpRequest.new.get(base + '/nginx_var?name=request')["body"]
  t.assert_equal 'name=query_string', HttpRequest.new.get(base + '/nginx_var?name=query_string')["body"]
end

t.assert('ngx_mruby - Nginx.return', 'location /service_unavailable') do
  res = HttpRequest.new.get base + '/service_unavailable'
  t.assert_equal 503, res.code
end

t.assert('ngx_mruby - Nginx.return 200 and body', 'location /return_and_body') do
  res = HttpRequest.new.get base + '/return_and_body'
  t.assert_equal "body", res["body"]
  t.assert_equal 200, res.code
end

t.assert('ngx_mruby - Nginx.return 200 dont have body', 'location /return_and_error') do
  res = HttpRequest.new.get base + '/return_and_error'
  t.assert_equal 500, res.code
end

t.assert('ngx_mruby - raise error with no response body', 'location /raise_and_no_response') do
  res = HttpRequest.new.get base + '/raise_and_no_response'
  t.assert_equal 500, res.code
end

#t.assert('ngx_mruby - request_body', 'location /request_body') do
#  res = HttpRequest.new.post base + '/request_body', "request body test"
#  t.assert_equal "request body test", res["body"]
#end

t.report
