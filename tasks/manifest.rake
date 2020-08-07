# frozen_string_literal: true

require "rake/tasklib"

# Tasks to create and check Manifest.txt
class ManifestTask < Rake::TaskLib
  attr_accessor :manifest_file, :patterns

  def initialize(name = :manifest)
    super()

    self.manifest_file = "Manifest.txt"
    self.patterns = ["**/*"]

    yield self if block_given?

    namespace name do
      define_tasks
    end
  end

  private

  def gemmable_files
    Rake::FileList.new(*patterns)
  end

  def manifest_files
    File.read(manifest_file).split
  end

  def define_tasks
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
end

ManifestTask.new do |t|
  t.patterns = ["{docs,examples,lib}/**/*", "COPYING.LIB"]
end
