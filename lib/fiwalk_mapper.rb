require 'lib/fiwalk'
require 'digest/sha1'
require 'time'

Ftypes = {
  '-' => 'Unknown type',
  'r' => 'Regular file',
  'd' => 'Directory',
  'c' => 'Character device',
  'b' => 'Block device',
  'l' => 'Symbolic link',
  'p' => 'Named FIFO',
  's' => 'Shadow',
  'h' => 'Socket',
  'w' => 'Whiteout',
  'v' => 'TSK Virtual file',
}

def to_b(v)
  return [true, "true", 1, "1", "T", "t"].include?(v.class == String ? v.downcase : v)
end

def ext e
  return '(None)' if File.extname(e).empty?
  File.extname(e)
end

def path p
   path = p.split('/')
   path[0..-2].join('/')
end

def ftype t
  Ftypes[t]
end

class FiwalkMapper
  attr :filename
  attr :file_id
  attr :metadata
  attr :from_image
  
  def initialize(doc_path)
    @filename = doc_path
    if File.extname(doc_path) == '.xml'
      raw = File.read doc_path
      raw.to_s.gsub(/\n+|\t+/, '').gsub(/ +/, ' ').strip
      @from_image = false
    else
      raw = %x[fiwalk -fx #{doc_path}]
      @from_image = true
    end
    @file_id = val_to_id File.basename(doc_path, '.*')
    @metadata = Fiwalk.parse(raw)
  end
  
  def val_to_id(v)
    v.downcase.gsub('\s+', '_').gsub(/\W+/, '_').gsub(/ /, '_').gsub(/\.xml/, '').gsub(/^ +| $/, '')
  end
  
  def shaify(v, w)
    sha = Digest::SHA1.new
    sha.update v
    sha.update '_'
    sha.update w
    sha.hexdigest
  end
  
  def unepoch(e)
    Time.at(e.to_i).utc.iso8601.to_s
  end
  
  def contents fobj
    %x[icat #{@filename} #{fobj.inode}]
  end
  
  def get_solr_docs
    docs = []
    @metadata.volumes.each do |volume|
      volume.fileobjects.each do |fileobject|
        doc = {
          :atime_dt => unepoch(fileobject.atime),
          :compressed_b => to_b(fileobject.compressed),
          #:contents_display
          #:contents_t
          :crtime_dt => unepoch(fileobject.crtime),
          :ctime_dt => unepoch(fileobject.ctime),
          :dtime_dt => unepoch(fileobject.dtime),
          :encrypted_b => to_b(fileobject.encrypted), 
          :extension_facet => ext(fileobject.filename),
          :fileid_i => fileobject.fileid.to_i,
          :filename_display => File.basename(fileobject.filename.to_s),
          :filename_full_display => '/' + fileobject.filename.to_s,
          :filename_sort => '/' + fileobject.filename.to_s,
          :filename_t => '/' + fileobject.filename.to_s,
          :filesize_i => fileobject.filesize.to_i,
          :fragments_i => fileobject.fragments.to_i,
          :gid_i => fileobject.gid.to_i,
          :id => shaify(@file_id, fileobject.inode),
          :inode_i => fileobject.inode.to_i,
          :libmagic_display => fileobject.libmagic,
          :libmagic_facet => fileobject.libmagic,
          :md5_s => fileobject.md5,
          :meta_type_i => fileobject.meta_type,
          :mode_facet => fileobject.mode,
          :mode_s => fileobject.mode,
          :mtime_dt => unepoch(fileobject.mtime),
          :nlink_i => fileobject.nlink.to_i,
          :name_type_s => ftype(fileobject.name_type),
          :partition_i => fileobject.partition.to_i,
          :path_facet => path(fileobject.filename),
          :path_s => '/' + path(fileobject.filename),
          :sha1_s => fileobject.sha1,
          :uid_i => fileobject.uid.to_i,
          :volume_display => @file_id,
          :volume_facet => @file_id
        }
        doc[:text] = doc.values.join ' '
        docs << doc
      end
    end
    docs
  end
end