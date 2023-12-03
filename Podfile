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
  end
end
