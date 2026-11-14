# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'AnimeNotesApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AnimeNotesApp
  
  pod 'RealmSwift' # ローカルデータベースにアクセスするためのライブラリ
  pod 'Firebase/Auth' # Firebase認証のためのライブラリ
  pod 'Firebase/Analytics'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'

  target 'AnimeNotesAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'AnimeNotesAppUITests' do
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
    # 新しいXcodeのclangが '-G' 系フラグを拒否するため、BoringSSL-GRPC の不正なフラグを除去する
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end

  # gRPC-Core 1.49 は新しいclangでテンプレート構文エラーになるため修正する
  basic_seq = File.join(installer.sandbox.root, 'gRPC-Core/src/core/lib/promise/detail/basic_seq.h')
  if File.exist?(basic_seq)
    File.chmod(0644, basic_seq)
    content = File.read(basic_seq)
    File.write(basic_seq, content.gsub('Traits::template CallSeqFactory(', 'Traits::CallSeqFactory('))
  end
end
