module TargetIO
  class Deploy
    def create(file)
      Chef::Log.trace("Touching #{file} to create it")
      TargetIO::FileUtils.touch(file)
    end

    def deploy(src, dst)
      Chef::Log.trace("Reading modes from remote file #{dst}")
      stat = ::TargetIO::File.stat(dst)
      mode = stat.mode.nil? ? nil : stat.mode & 07777
      uid  = stat.uid
      gid  = stat.gid

      Chef::Log.trace("Uploading local temporary file #{src} as remote file #{dst}")
      ::TargetIO::File.upload(src, dst)

      # Skip Unix permission restoration on platforms (e.g. Windows) that don't expose mode/uid/gid
      unless mode.nil? && uid.nil? && gid.nil?
        Chef::Log.trace("Applying mode = #{mode.to_s(8)}, uid = #{uid}, gid = #{gid} to #{dst}")
        ::TargetIO::File.chown(uid, nil, dst)
        ::TargetIO::File.chown(nil, gid, dst)
        ::TargetIO::File.chmod(mode, dst)
      end

      # Local clean up
      File.delete(src)
    end
  end
end
