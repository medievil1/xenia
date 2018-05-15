project_root = "../../.."
include(project_root.."/tools/build")
local qt = premake.extensions.qt

group("src")
project("xenia-app")
  uuid("d7e98620-d007-4ad8-9dbd-b47c8853a17f")
  kind("WindowedApp")
  targetname("xenia")
  language("C++")
  links({
    "capstone",
    "gflags",
    "glew",
    "glslang-spirv",
    "imgui",
    "libavcodec",
    "libavutil",
    "snappy",
    "spirv-tools",
    "volk",
    "xenia-apu",
    "xenia-apu-nop",
    "xenia-base",
    "xenia-core",
    "xenia-cpu",
    "xenia-cpu-backend-x64",
    "xenia-debug-ui",
    "xenia-gpu",
    "xenia-gpu-null",
    "xenia-gpu-vulkan",
    "xenia-hid",
    "xenia-hid-nop",
    "xenia-kernel",
    "xenia-ui",
    -- "xenia-ui-qt",
    "xenia-ui-spirv",
    "xenia-ui-vulkan",
    "xenia-vfs",
    "xxhash",
  })

  -- Setup Qt libraries
  qt.enable()
  qtmodules{"core", "gui", "widgets"}
  qtprefix "Qt5"
  if os.getenv("QT_LIB") then
    qtlibpath(os.getenv("QT_LIB"))
  end

  configuration {"Debug"}
    qtsuffix "d"
  configuration {}

  flags({
    "WinMain",  -- Use WinMain instead of main.
  })
  defines({
  })
  includedirs({
    project_root.."/third_party/gflags/src",
  })
  local_platform_files()
  files({
    "xenia_main.cc",
    "../base/main_"..platform_suffix..".cc",

    -- Qt files
    "*.qrc",
  })
  filter("platforms:Windows")
    resincludedirs({
      project_root,
    })

  filter("platforms:Linux")
    links({
      "X11",
      "xcb",
      "X11-xcb",
      "GL",
      "vulkan",
    })

  filter("platforms:Windows")
    links({
      "xenia-apu-xaudio2",
      "xenia-hid-winkey",
      "xenia-hid-xinput",
    })

  filter("platforms:Windows")
    -- Only create the .user file if it doesn't already exist.
    local user_file = project_root.."/build/xenia-app.vcxproj.user"
    if not os.isfile(user_file) then
      debugdir(project_root)
      debugargs({
        "--flagfile=scratch/flags.txt",
        "2>&1",
        "1>scratch/stdout.txt",
      })
      debugenvs({
        "PATH=" .. qt.defaultpath .. "/bin",
      })
    end
