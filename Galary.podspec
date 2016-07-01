Pod::Spec.new do |s|
s.name         = 'Galary'
s.version      = '1.0.6'
s.summary      = '使用Photos Framework制作的仿微信图片选择器，支持自定义嵌入其他功能页面'
s.homepage     = 'https://github.com/liyaozhong/Galary'
s.license      = 'MIT'
s.author       = { 'liyaozhong' => 'yun.zhongyue@163.com' }
s.source       = { :git => 'https://github.com/liyaozhong/Galary.git', :tag => s.version.to_s}
s.resource     = 'Galary/MyGalary/*.{png,xib}'
s.platform     = :ios
s.requires_arc = true
s.source_files = 'Galary/MyGalary/*.{h,m}'
s.ios.deployment_target = '8.0'
end