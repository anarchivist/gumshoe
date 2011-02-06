require 'sax-machine'

class ByteRun
  # TODO: Figure out how to get access to attributes w/ sax-machine
  include SAXMachine
  element :run
end

class FileObject
  include SAXMachine
  element :filename
  element :partition
  element :id
  element :name_type
  element :filesize
  element :alloc
  element :used
  element :inode
  element :meta_type
  element :mode
  element :nlink
  element :uid
  element :gid
  element :mtime
  element :atime
  element :libmagic
  elements :byte_runs, :class => ByteRun
  element :hashdigest, :as => :md5, :with => {:type => "md5"}
  element :hashdigest, :as => :sha1, :with => {:type => "md5"}
end

class Volume
  include SAXMachine
  element :partition_offset
  element :block_size
  element :ftype_str, :as => :ftype
  element :block_count
  element :first_block
  element :last_block
  element :allocated_only
  elements :fileobject, :as => :fileobjects, :class => FileObject
end

class Fiwalk
  include SAXMachine
  element :metadata # needs work
  element :creator  # needs work
  elements :volume, :as => :volumes, :class => Volume
  element :runstats # needswork
end  