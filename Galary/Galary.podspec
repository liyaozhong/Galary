Pod::Spec.new do |s|
s.name         = 'Galary'
s.version      = '1.0.0'
s.summary      = '仿微信选择图片，支持自定义'
s.homepage     = 'https://github.com/liyaozhong/Galary'
s.license      = 'MIT'
s.author       = { 'liyaozhong' => 'yun.zhongyue@163.com' }
s.source       = { :git => 'https://github.com/liyaozhong/Galary.git', :tag => s.version.to_s}
s.platform     = :ios
s.requires_arc = true
s.source_files = 'Galary/MyGalary/*'
s.ios.deployment_target = '8.0'
end