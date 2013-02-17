require 'sax-machine'
require 'time'

def isone?(val)
  # Return true if something is one (number or string).
  # Based on Python isone function packaged in fiwalk's dfxml.py
  # Unlike Python, we probably don't need to catch a TypeError exception.
  true ? val.to_i == 1 : false
end

module Dfxml
  
  module Parser

    class ByteRun
      include SAXMachine
      attribute :file_offset
      attribute :fs_offset
      attribute :img_offset
      attribute :len
    end
    
    class ByteRunGroup
      include SAXMachine
      elements :byte_run, :as => :runs, :class => ByteRun
    end

    class FileObject
      include SAXMachine
      element :alloc # TSK_FS_META.flags
      element :atime # file content access time
      element :compressed # TSK_FS_META.flags
      element :bkup_time # HFS+ only
      element :crtime # created time
      element :ctime # file/metadata status change time
      element :dtime # deletion time (ext only)
      element :encrypted
      element :filename
      element :filesize
      element :fragments
      element :gid
      element :id_
      element :inode
      element :libmagic
      element :link_target
      element :meta_type
      element :mode
      element :mtime # content modification time
      element :name_type
      element :nlink # number of links to this file 
      element :orphan # TSK_FS_META.flags
      element :partition
      element :seq # sequence number (ntfs only)
      element :uid
      element :unalloc # TSK_FS_META.flags
      element :unused # TSK_FS_META.flags
      element :used # TSK_FS_META.flags
      element :byte_runs, :class => ByteRunGroup
      element :hashdigest, :as => :md5, :with => {:type => "md5"}
      element :hashdigest, :as => :sha1, :with => {:type => "sha1"}
      element :hashdigest, :as => :sha256, :with => {:type => "sha256"}
      # elements from fido extractor plugin
      # element "PUID", :as => :pronom_puid
      # element "PronomFormat", :as => :pronom_format
      
      # Begin timestamp methods
      #
      # It would be preferable to have a way to call these matching on
      # element name.
      
      def atime=(val)
        @atime = Time.parse(val)
      end
      
      def bkup_time=(val)
        @bkup_time = Time.parse(val)
      end
      
      def crtime=(val)
        @crtime = Time.parse(val)
      end
      
      def dtime=(val)
        @dtime = Time.parse(val)
      end
      
      def mtime=(val)
        @mtime = Time.parse(val)
      end
      
      # End timestamp methods
      
      # Begin boolean methods
      #
      # Convenience methods for flags expressed in the metadata layer of
      # file systems. However, they're not terribly robust and are considered
      # workarounds for the way fiwalk expresses metadata-layer flags in
      # its output. In fiwalk-generated dfxml, when an element should be
      # considered true, the element contains the value "1". However, the
      # expression in output doesn't necessarily fit with what humans expect.
      # For example, the allocated/unallocated flags are expressed in
      # fiwalk's output as follows:
      #
      # - when allocated: <alloc>1</alloc>
      # - when unallocated: <unalloc>1</unalloc>
      # 
      # For more clarification, see fiwalk_tsk.cpp's handling for
      # fs_file->meta in process_tsk_file.
            
      def allocated?
        isone?(@alloc) && !isone?(@unalloc)
      end
      
      def compressed?
        isone?(@compressed)
      end
      
      def encrypted?
        # encrypted is not a flag, but we'll treat it like one.
        isone?(@encrypted)
      end
      
      def orphan?
        isone?(@orphan)
      end
      
      def used?
        isone?(@used) && !isone?(@unused)
      end
      
      # End boolean methods      
      
      def type
        Dfxml::CharacterFileTypes[@name_type] ||= Dfxml::NumericFileTypes[@meta_type.to_i]
      end
      
    end

    class Volume
      include SAXMachine
      attribute :offset
      element :partition_offset
      element :block_size
      element :ftype
      element :ftype_str      
      element :block_count
      element :first_block
      element :last_block
      element :allocated_only
      elements :fileobject, :as => :fileobjects, :class => FileObject
      
      def ftype=(val)
        @ftype ||= Dfxml::NumericFileSystemTypes[val.to_i]
      end
      
      def ftype_str=(val)
        @ftype ||= val.to_sym
      end
      
    end
    
    class ExecutionEnvironment
      include SAXMachine
      element :os_sysname
      element :os_release
      element :os_version
      element :host
      element :arch
      element :command_line
      element :start_time
    end
    
    class BuildLibrary
      include SAXMachine
      attribute :name
      attribute :version
    end
    
    class BuildEnvironment
      include SAXMachine
      element :compiler
      elements :library, :as => :libraries, :class => BuildLibrary
    end
    
    class Creator
      include SAXMachine
      element :program
      element :version
      element :build_environment, :class => BuildEnvironment
      element :execution_environment, :class => ExecutionEnvironment
    end
    
    class Source
      include SAXMachine
      element :image_filename
    end
    
    class Metadata
      include SAXMachine
      element "dc:type", :as => :type
    end
    
    class RuntimeStatistics
      include SAXMachine
      element :user_seconds
      element :system_seconds
      element :maxrss
      element :reclaims
      element :faults
      element :swaps
      element :inputs
      element :outputs
      element :stop_time
    end
    
    class DFXML
      include SAXMachine
      attribute :version
      element :metadata, :class => Metadata
      element :creator, :class => Creator
      element :source, :class => Source
      elements :volume, :as => :volumes, :class => Volume
      element :runstats, :class => RuntimeStatistics
    end  
  end
  
end