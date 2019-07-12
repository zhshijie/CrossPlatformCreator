#!/usr/bin/python3
# -*- coding: utf-8 -*
import os
import shutil 

projectName = ""
projectPath = ""
androidPackage = ""
cococaBundleId = ""
# projectTotalPath = projectPath + projectName
projectTotalPath = "" 

# 输入项目名称
def inputProjectName():
  global projectName
  while True:
    projectName = input("项目名称: ") 
    if not projectName:
      print("请重新输入项目名称\n")
    else:
      return

# 输入项目路径
def inputProjectPath():
  global projectPath
  projectPath = input("项目路径: ")

# 输入安卓 SDK 的包路径
def inputAndroidPackage():
  global androidPackage
  global projectName
  defalutAndroidPackage = ("com.seewo.%s"%(projectName))
  defalutAndroidPackage = defalutAndroidPackage.lower()
  androidPackage = input(("安卓 SDK 的包名(默认值是 %s): "%(defalutAndroidPackage)))
  if not androidPackage:
    androidPackage = ("com.seewo.%s"%(projectName))
  androidPackage =  androidPackage.lower()

# 输入 iOS SDK 的 bundleId
def inputCocoaBundleId():
  global cococaBundleId
  global projectName
  cococaBundleId = input("Cocoa 的 BundleId(默认值是 com.cvte.%s.sdk): "%(projectName))
  if not cococaBundleId:
    cococaBundleId = "com.cvte.%s.sdk"%(projectName)


# 创建新的目录
def mkdir(projectPath):
  totalPath = projectPath
  folder = os.path.exists(totalPath)
  if not folder:
    os.makedirs(totalPath)
  else:
    print ("目录已存在")

# 创建项目目录
def createProjectDir():
  global projectPath
  global projectName
  global projectTotalPath
  projectTotalPath = projectPath + '/' + projectName
  try:
    mkdir(projectTotalPath)
    print("创建项目根目录")
  except:
    print("创建项目根目录失败")
    pass


# 遍历指定目录，并将获取遍历到的路径回调出去
def traverseDir(rootDir, action): 
     for lists in os.listdir(rootDir): 
        path = os.path.join(rootDir, lists)
        action(path)

# 复制文件到指定的路径
def copyfile(infile, outfile):
    try:
        shutil.copy(infile, outfile)
    except:
        print('''Can't open this file''')
        return

# 复制目录到指定路径
def copydir(indir, outdir):
    try:
        shutil.copytree(indir,outdir)
    except:
        print('This dir is wrong')

# 文件复制到 project 根目录下
def copyFileToProject(filePath):
  global projectTotalPath
  filename = filePath.split("/")[-1]
  projectFileName = projectTotalPath + '/' + filename
  if os.path.isdir(filePath):
    copydir(filePath, projectFileName)
  else:
    copyfile(filePath, projectFileName)
  
# 将初始化配置信息 copy 到项目目录中
def copyConfigFileToProject():
  print("项目目录开始初始化..")
  configDirPath = os.getcwd() + '/' + 'config'
  traverseDir(configDirPath, copyFileToProject)

# 文件复制到 project 根目录下
def copyFileToTargetPath(filePath, targetPath):
  filename = filePath.split("/")[-1]
  projectFileName = targetPath + '/' + filename
  if os.path.isdir(filePath):
    copydir(filePath, projectFileName)
  else:
    copyfile(filePath, projectFileName)


def copyDemoConfigToCxxDir(path):
  configDirPath = os.getcwd() + '/' + 'demoConfig/src'
  def copyToCxxDir(filePath): 
    copyFileToTargetPath(filePath, path)
  traverseDir(configDirPath, copyToCxxDir)

def CxxDemoHeaderData():
  return "void hello();"

def createCxxDemoHeader(path):
  headerName = projectName[0].upper()+projectName[1:]
  filename = path + '/' + headerName + '.h'
  with open(filename,'w') as f:
    demoHeaderData = CxxDemoHeaderData()
    f.write(demoHeaderData)


def createCxxHeader(path):
 #创建 C++ Header 目录
  headerPath = path + '/header'
  mkdir(headerPath)
  # 创建 demo.h 文件
  createCxxDemoHeader(headerPath)

def createCxxDemoSrc(path):
  cxxDemoFileName = path + '/src/' +projectName + '.cc'
  with open(cxxDemoFileName,'w') as f:
    demoHeaderData = '''
    #include <stdio.h>

    #ifdef __APPLE__
    void loadCocoaService();
    #endif

    void hello()
    {
      printf(\"hello cmake!\\n\");
    }
    '''
    f.write(demoHeaderData)


# 替换原文件中的占位符
def modifyFile(path): 
  data = ''
  try:
    with open(path, 'r+') as f:
      for line in f.readlines():
        packageId = androidPackage.replace('.','_')
        packagePath = androidPackage.replace('.','/')
        cxxLibararyName = projectName + 'SDK'
        cxxProjectName = projectName + 'SDK'
        line = line.replace("$$projectName$$", projectName)
        line = line.replace("$$packageId$$", packageId)
        line = line.replace('$$packagePath$$', packagePath)
        line = line.replace("$$libnameName$$", cxxProjectName)
        line = line.replace('$$BundleId$$', cococaBundleId)
        data += line
  except:
    print("重写 C++ CMakeLists 中的项目名失败")
    pass
  
  try:
     with open(path, 'w+') as f:
       f.writelines(data)
  except:
    print("重写 C++ CMakeLists 中的项目名失败")
    pass

def modifyDir(path):
  jniDir = path
  for lists in os.listdir(jniDir): 
        if lists.find('.DS_Store') == 0:
          continue
        path = os.path.join(jniDir, lists)
        newPath = path.replace('$$projectName$$', projectName)
        os.rename(path, newPath)
        modifyFile(newPath)


# 初始化 C++ 源码目录
def createCxxDir(path):
  print("初始化 c++ 实例代码")
  #创建 C++ 源码目录
  CXXSrcPath = path + '/src'
  #创建 header 目录
  createCxxHeader(CXXSrcPath)
  # 修改 CMakeLists.text 中的项目名称和库名
  modifyFile(CXXSrcPath + '/CMakeLists.txt')
  # 创建 c++ demo 源码
  createCxxDemoSrc(CXXSrcPath)
  # 修改 jni 文件
  modifyDir(CXXSrcPath + '/jni')


def modifyCocoaDir(sdkPath):
  print("初始化 Cocoa 实例代码")
  modifyDir(sdkPath + '/cocoa/src')
  modifyDir(sdkPath + '/cocoa/demo')
  modifyFile(sdkPath + '/cocoa/CMakeLists.txt')
  modifyFile(sdkPath + '/cocoa/info.plist')

# 根据安卓的包名，创建响应的 Android 目录
def createAndroidPackageDir(sdkPath):
  finalPath = sdkPath + '/android'
  dirs = androidPackage.split('.')
  for dir in dirs:
    finalPath = finalPath + '/' + dir
    mkdir(finalPath)
  return finalPath


# 创建 Java 的demo 
def createJaveDemoSrc(path): 
  print("初始化 Android 实例代码")
  cxxDemoFileName = path + '/' + projectName + 'Sdk.java'
  with open(cxxDemoFileName,'w') as f:
    javaDemoData = '''
    package %s;
    
    public class %sSdk {

      static {
          System.loadLibrary("%sSDK");
      }   

      public native void hello();
    }'''%(androidPackage, projectName,projectName)
    f.write(javaDemoData)



def main():
  global projectTotalPath
  inputProjectName()
  inputProjectPath()
  inputAndroidPackage()
  inputCocoaBundleId()
  
  createProjectDir()
  copyConfigFileToProject()
  # 修改根目录的 CMakeLists 文件
  modifyFile(projectTotalPath + '/CMakeLists.txt')
  # 创建 SDK 目录
  sdkPath = projectTotalPath + '/sdk'

  createCxxDir(sdkPath)
  # 修改 cocoa src 文件
  modifyCocoaDir(sdkPath)

  finalPath = createAndroidPackageDir(sdkPath)
  createJaveDemoSrc(finalPath)
  print("创建完成，项目路径是：%s"%(projectTotalPath))



main()
