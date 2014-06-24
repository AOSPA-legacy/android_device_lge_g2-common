# Copyright (C) 2012 The Android Open Source Project
# Copyright (C) 2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
#
# This leverages the loki_patch utility created by djrbliss which allows us
# to bypass the bootloader checks on jfltevzw and jflteatt
# See here for more information on loki: https://github.com/djrbliss/loki
#

"""Custom OTA commands for LG devices with locked bootloaders"""

def FullOTA_InstallEnd(info):
  info.script.script = [cmd for cmd in info.script.script if not "boot.img" in cmd]
  info.script.script = [cmd for cmd in info.script.script if not "show_progress(0.100000, 0);" in cmd]
  info.script.AppendExtra('package_extract_file("boot.img", "/tmp/boot.img");')
  info.script.AppendExtra('assert(run_program("/system/bin/loki.sh") == 0);')
  info.script.AppendExtra('delete("/system/bin/loki.sh");')
  info.script.AppendExtra('package_extract_file("system/bin/dump_image.sh", "/tmp/dump_image.sh");')
  info.script.AppendExtra('package_extract_file("system/bin/bootimg.sh", "/tmp/bootimg.sh");')
  info.script.AppendExtra('package_extract_file("system/bin/unpackbootimg", "/tmp/unpackbootimg");')
  info.script.AppendExtra('package_extract_file("system/bin/mkbootimg", "/tmp/mkbootimg");')
  info.script.AppendExtra('package_extract_file("system/bin/loki_tool", "/tmp/loki_tool");')
  info.script.AppendExtra('set_perm(0, 0, 0775, "/tmp/dump_image.sh");')
  info.script.AppendExtra('set_perm(0, 0, 0775, "/tmp/bootimg.sh");')
  info.script.AppendExtra('set_perm(0, 0, 0775, "/tmp/unpackbootimg");')
  info.script.AppendExtra('set_perm(0, 0, 0775, "/tmp/mkbootimg");')
  info.script.AppendExtra('set_perm(0, 0, 0775, "/tmp/loki_tool");')
  info.script.AppendExtra('ui_print("detecting your screen type...");')
  info.script.AppendExtra('ui_print("Dumping current boot.img...");')
  info.script.AppendExtra('run_program("/tmp/dump_image.sh", "qcom", "boot", "/bin");')
  info.script.AppendExtra('ui_print("hacking boot.img...");')
  info.script.AppendExtra('assert(run_program("/tmp/bootimg.sh") == 0);')
  info.script.AppendExtra('delete("/system/bin/dump_image.sh");')
  info.script.AppendExtra('delete("/system/bin/bootimg.sh");')
  info.script.AppendExtra('delete("/system/bin/mkbootimg");')
  info.script.AppendExtra('delete("/system/bin/unpackbootimg");')
  info.script.AppendExtra('delete("/system/bin/loki_tool");')
