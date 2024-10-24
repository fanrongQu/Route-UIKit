

Pod::Spec.new do |spec|

  spec.name         = "Route-UIKit"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Route-UIKit."

  spec.description  = <<-DESC
                Route-UIKit是一个swift语言的基于UIKit的页面路由框架
                   DESC
  spec.homepage     = "https://github.com/fanrongQu/Route-UIKit"
  spec.license      = {:type => 'MIT', :file => "LICENSE"}
  spec.author       = {"FR" => "1366225686@qq.com"}
  spec.source       = {:git => "https://github.com/fanrongQu/Route-UIKit.git", :tag => spec.version.to_s}
  spec.source_files  = "Sources/**/*.swift"
  spec.platform     = :ios
  spec.requires_arc = true
  spec.swift_version = '5.0'
  spec.ios.deployment_target	= "9.0"
  spec.framework = "Foundation"
end
