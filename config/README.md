## 依赖环境

* python(>=2.7.11),

* cmake(3.8.x),

* conan(>=0.30.x),

* 添加内部仓库 `conan remote add nuget_conan https://artifactory.gz.cvte.cn/artifactory/api/conan/conan-local --insert`

* 如果通过conan search -r=nuget_conan列出的包却不能拉下来，则可能是本地的配置和仓库的不一致，本地的默认配置在C:\Users\user\.conan\profiles\default

* NDK(android-ndk-r13b) 编译 android 需要

* 配置 `ANDROID_NDK_HOME` 环境变量指向 NDK 目录，编译 android 需要

> 支持 VS2017, VS2015, Android Studio(>3.x), Xcode(9.2+)

## 工程的生成

- 生成 iOS 工程

`$python bootstrap.py ios`

- 生成 Mac 工程

`$python bootstrap.py osx`

- 生成 windows VS2017 工程

`$python bootstrap.py win2017`

- 生成 windows VS2015 工程

`$python bootstrap.py win2015`

- 生成 Android 工程

`1. $python bootstrap.py android`

`2. $python build.py android`


## 工程的说明

 `./build/` 目录下的生成文件都由 `bootstrap.py` 脚本生成，各个平台的 SDK 工程的编译可在 `./sdk/` 目录下找对应平台的 workspace
 