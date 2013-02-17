require 'rubygems'
require 'nokogiri'

module Dfxml
  
  NumericFileTypes = {
    # numeric values are in tsk3/fs/tsk_fs.h - TSK_FS_NAME_TYPE_ENUM
    # returned within fiwalk's fileobjects as meta_type
    0 => :unknown,
    1 => :file,
    2 => :directory,          
    3 => :named_pipe,
    4 => :character_device,
    5 => :block_device,
    6 => :symlink,
    7 => :shadow,
    8 => :socket,
    9 => :whiteout,
    10 => :tsk_virtual_file,
  }
  
  CharacterFileTypes = {
    # character values are what are returned from tsk's cli utils
    # returned within fiwalk's fileobjects as name_type
    '-' => :unknown,
    'r' => :file,
    'd' => :directory,          
    'c' => :character_device,
    'b' => :block_device,
    'l' => :symlink,
    'p' => :named_pipe,
    's' => :shadow,
    'h' => :socket,
    'w' => :whiteout,
    'v' => :tsk_virtual_file
  }
  
  NumericFileSystemTypes = {
    # numeric values are in tsk3/fs/tsk_fs.h - TSK_FS_TYPE_ENUM
    # symbol names based on fs_type_table in tsk3/fs/fs_types.c
    0 => :unknown,
    1 => :ntfs, # autodetected
    2 => :fat12,
    4 => :fat16,
    8 => :fat32,
    14 => :fat, # autodetected
    16 => :ufs1,
    # 32 => :ufs1b, # not expressed in fs_type_table; legacy value
    64 => :ufs2,
    112 => :ufs, # autodetected
    128 => :ext2,
    256 => :ext3,
    # 384 => :ext, # autodetected - not expressed in fs_type_table
    512 => :swap,
    1024 => :raw,
    2048 => :iso9660,
    4096 => :hfs, # actually HFS+; using :hfs based on TSK convention
    # 4294967295 => :unsupported
  }
  
end
