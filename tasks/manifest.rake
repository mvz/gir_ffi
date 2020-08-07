# frozen_string_literal: true

namespace :manifest do
  def gemmable_files
    Rake::FileList["{docs,examples,lib}/**/*", "COPYING.LIB"]
  end

  def manifest_files
    File.read("Manifest.txt").split
  end

  desc "Create or update manifest"
  task :generate do
    File.open("Manifest.txt", "w") do |manifest|
      gemmable_files.each { |file| manifest.puts file }
    end
  end

  desc "Check manifest"
  task :check do
    unless gemmable_files == manifest_files
      raise "Manifest check failed, try recreating the manifest"
    end
  end
end
