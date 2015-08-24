Pod::Spec.new do |s|
  s.name             = "LETimeIntervalPicker"
  s.version          = "2.0.2"
  s.summary          = "A UIDatePicker for time intervals."
  s.description      = <<-DESC
                       LETimeIntervalPicker lets you pick a time interval with hours, minutes and seconds.
                       DESC
  s.homepage         = "https://github.com/JimVanG/LETimeIntervalPicker"
  s.screenshots      = "http://i.imgur.com/qi9fHVN.png"
  s.license          = 'MIT'
  s.author           = "JimVanG"
  s.source           = { :git => "https://github.com/JimVanG/LETimeIntervalPicker.git", :tag => "2.0.2-allogy" }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'LETimeIntervalPicker' => ['Pod/Assets/**/*']
  }

  s.frameworks = 'UIKit'
end