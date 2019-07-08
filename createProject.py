#!/usr/bin/python3
# -*- coding: utf-8 -*
import os
import shutil 

while True:
  projectName = input("项目名称: ") 
  if not projectName:
    print("请重新输入项目名称\n")
  else:
    break

projectPath = input("项目路径: ")

defalutAndroidPackage = ("com.seewo.%s"%(projectName))
defalutAndroidPackage = defalutAndroidPackage.lower()
androidPackage = input(("安卓 SDK 的包名(默认值是 com.seewo.%s): "%(defalutAndroidPackage)))
if not androidPackage:
  androidPackage = ("com.seewo.%s"%(projectName))

androidPackage =  androidPackage.lower()


cococaBundleId = input("Cocoa 的 BundleId(默认值是 com.cvte.%s.sdk): "%(projectName))
if not cococaBundleId:
  cococaBundleId = "com.cvte.%s.sdk"%(projectName)

# 创建新的目录
def mkdir(projectPath):
  totalPath = projectPath
  folder = os.path.exists(totalPath)
  print("项目完整路径", totalPath)
  if not folder:
    os.makedirs(totalPath)
  else:
    print ("目录已存在")

projectTotalPath = projectPath + '/' + projectName
mkdir(projectTotalPath)


def traverseDir(rootDir, action): 
     for lists in os.listdir(rootDir): 
        path = os.path.join(rootDir, lists)
        action(path)

def copyfile(infile,outfile):
    try:
        shutil.copy(infile,outfile)
    except:
        print('''Can't open this file''')
        return

def copydir(indir, outdir):
    try:
        shutil.copytree(indir,outdir)
    except:
        print('This dir is wrong')

# 文件复制到 project 根目录下
def copyFileToProject(filePath):
  filename = filePath.split("/")[-1]
  projectFileName = projectTotalPath + '/' + filename
  print("projectFileName = ", projectFileName)
  if os.path.isdir(filePath):
    copydir(filePath, projectFileName)
  else:
    copyfile(filePath, projectFileName)
  
def copyConfigFileToProject():
  configDirPath = os.getcwd() + '/' + 'config'
  traverseDir(configDirPath, copyFileToProject)



def modifyCMakeListsProjectName(path):
  data = ''
  try:
    with open(path, 'r+') as f:
      for line in f.readlines():
        if(line.find('project($$projectName$$)') == 0):
            line = 'project(%s' % (projectName,) + ')\n'
        data += line
  except expression:
    print("重写 CMakeLists 中的项目名失败，error = ", expression)
    pass
  
  try:
     with open(path, 'r+') as f:
       f.writelines(data)
  except expression:
    print("重写 CMakeLists 中的项目名失败，error = ", expression)
    pass
 



copyConfigFileToProject()

modifyCMakeListsProjectName(projectTotalPath + '/CMakeLists.txt')



# 创建 SDK 目录
sdkPath = projectTotalPath + '/sdk'
mkdir(sdkPath)


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


# 根据 projectName 和 BundleId，修改制定的参数
def modiyCxxMakeList(path):
  data = ''
  try:
    with open(path, 'r+') as f:
      for line in f.readlines():
        cxxLibararyName = projectName + 'SDK'
        cxxProjectName = projectName + 'SDK'
        line = line.replace("$$projectName$$", cxxProjectName)
        line = line.replace("$$libnameName$$", cxxProjectName)
        line = line.replace('$$BundleId$$', cococaBundleId)
        data += line
  except expression:
    print("重写 C++ CMakeLists 中的项目名失败，error = ", expression)
    pass
  
  try:
     with open(path, 'r+') as f:
       f.writelines(data)
  except expression:
    print("重写 C++ CMakeLists 中的项目名失败，error = ", expression)
    pass

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


def modifyFile(path): 
  print(path)
  data = ''
  try:
    with open(path, 'r+') as f:
      for line in f.readlines():
        packageId = androidPackage.replace('.','_')
        packagePath = androidPackage.replace('.','/')
        line = line.replace("$$projectName$$", projectName)
        line = line.replace("$$packageId$$", packageId)
        line = line.replace('$$packagePath$$', packagePath)
        data += line
  except:
    print("重写 C++ CMakeLists 中的项目名失败，error = ")
    pass
  
  try:
     with open(path, 'r+') as f:
       f.writelines(data)
  except:
    print("重写 C++ CMakeLists 中的项目名失败，error = ")
    pass

def modifyDir(path):
  jniDir = path
  for lists in os.listdir(jniDir): 
        print(lists)
        if lists.find('.DS_Store') == 0:
          continue
        path = os.path.join(jniDir, lists)
        newPath = path.replace('$$projectName$$', projectName)
        os.rename(path, newPath)
        modifyFile(newPath)




# 初始化 C++ 源码目录
def createCxxDir(path):
  #创建 C++ 源码目录
  CXXSrcPath = path + '/src'
  #创建 header 目录
  createCxxHeader(CXXSrcPath)

  # 修改 CMakeLists.text 中的项目名称和库名
  modiyCxxMakeList(CXXSrcPath + '/CMakeLists.txt')

  # 创建 c++ demo 源码
  createCxxDemoSrc(CXXSrcPath)

  # 修改 jni 文件
  modifyDir(CXXSrcPath + '/jni')


createCxxDir(sdkPath)

# 修改 cocoa src 文件
modifyDir(sdkPath + '/cocoa/src')


# 根据安卓的包名，创建响应的 Android 目录
finalPath = sdkPath + '/android'
def createAndroidPackageDir():
  global finalPath
  dirs = androidPackage.split('.')
  for dir in dirs:
    print(finalPath)
    finalPath = finalPath + '/' + dir
    mkdir(finalPath)

createAndroidPackageDir()


def createJaveDemoSrc(path):
  cxxDemoFileName = path + '/' + projectName + '.java'
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


createJaveDemoSrc(finalPath)