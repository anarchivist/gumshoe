require 'dfxml'
require 'nokogiri'
require 'digest/sha1'

module Dfxml
  
  class Solrizer
    attr :filename
    attr :file_id
    attr :reader
    attr :from_image
    
    def initialize(doc_path)
      @filename = doc_path
      if File.extname(doc_path) == '.xml'
        @reader = Nokogiri::XML::Reader(doc_path)
        @from_image = false
      else
        @reader = Nokogiri::XML::Reader(%x[fiwalk -c config/ficonfig.txt -fx #{doc_path}])
        @from_image = true
      end
      @file_id = val_to_id File.basename(doc_path, '.*')
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
    
    def contents(fobj)
      %x[icat #{@filename} #{fobj.inode}]
    end
    
    def get_solr_docs
      while @reader.read
        if @reader.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT and @reader.name == 'fileobject'
          fileobject = Dfxml::Parser::FileObject.parse(@reader.outer_xml)
          doc = {
            :allocated_b => fileobject.allocated?,
            :atime_dt => fileobject.atime,
            :compressed_b => fileobject.compressed?,
            #:contents_display
            #:contents_t
            :crtime_dt => fileobject.crtime,
            :ctime_dt => fileobject.ctime,
            :dtime_dt => fileobject.dtime,
            :encrypted_b => fileobject.encrypted?, 
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
            :mtime_dt => fileobject.mtime,
            :nlink_i => fileobject.nlink.to_i,
            :name_type_s => fileobject.type,
            :orphan_b => fileobject.orphan?,
            :partition_i => fileobject.partition.to_i,
            :path_facet => path(fileobject.filename),
            :path_s => '/' + path(fileobject.filename),
            # :pronom_format_s => fileobject.pronom_format,
            # :pronom_puid_facet => fileobject.pronom_puid,
            # :pronom_puid_s => fileobject.pronom_puid,
            :sha1_s => fileobject.sha1,
            :uid_i => fileobject.uid.to_i,
            :used_b => fileobject.used?,
            :volume_display => @file_id,
            :volume_facet => @file_id
          }
          doc[:text] = doc.values.join ' '
          yield doc
        end
      end
    end
  end
  
end