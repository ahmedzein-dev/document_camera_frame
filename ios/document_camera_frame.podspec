Pod::Spec.new do |s|
  s.name             = 'document_camera_frame'
  s.version          = '2.5.4'
  s.summary          = 'Flutter plugin for capturing and scanning documents.'
  s.description      = <<-DESC
    Provides DocumentCameraUIMode.camScanner which launches VNDocumentCameraViewController
    on iOS and returns scanned image paths over a method channel.
  DESC
  s.homepage         = 'https://github.com/ahmedzein-dev/document_camera_frame'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ahmad Zein' => 'ahmedzein.dev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.swift'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
