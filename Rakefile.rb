require 'rubygems'
require 'pathname'
require 'logger'
require 'fileutils'
require 'sprockets'

#task :default => :compile

ROOT        = Pathname(File.dirname(__FILE__))
LOGGER      = Logger.new(STDOUT)
BUNDLES     = %w( common.css scripts.js )
BUILD_DIR   = ROOT.join("build")
SOURCE_DIR  = ROOT.join("src")

STYLESHEETS = %w( common.css )
JAVASCRIPTS = %w( scripts.js )


#task :compile do
##	sprockets = Sprockets::Environment.new
#  sprockets = Sprockets::Environment.new(ROOT) do |env|
#    env.logger = LOGGER
#  end
#
##  sprockets.append_path 'src/javascripts'
##  sprockets.append_path 'src/stylesheets'
#  sprockets.append_path(SOURCE_DIR.join('javascripts').to_s)
#  sprockets.append_path(SOURCE_DIR.join('stylesheets').to_s)
#
#  BUNDLES.each do |bundle|
#    assets = sprockets.find_asset(bundle)
#    prefix, basename = assets.pathname.to_s.split('/')[-2..-1]
#    FileUtils.mkpath BUILD_DIR.join(prefix)
#
#    assets.write_to(BUILD_DIR.join(prefix, basename))
#    assets.to_a.each do |asset|
#      # strip filename.css.foo.bar.css multiple extensions
#      realname = asset.pathname.basename.to_s.split(".")[0..1].join(".")
#      asset.write_to(BUILD_DIR.join(prefix, realname))
#    end
#  end
#end

#desc "help"
#Rake::SprocketsTask.new do |t|
#	t.environment = Sprockets::Environment.new
#	t.output      = "./build"
#	t.assets      = BUNDLES
#end

sprockets = Sprockets::Environment.new(File.dirname(__FILE__))
sprockets.append_path 'src/javascripts'
sprockets.append_path 'src/stylesheets'

namespace :assets do
	desc "Compile all assets"
	task :compile do
	end

	namespace :compile do
	  desc "Compile CSS assets"
		task :css do
		end
		
		desc "Compile JS assets"
		task :js do
		end
	end
	
	desc "Minify CSS & JS assets"
	task :minify do
		
	end

	namespace :minify do
		desc "Minify CSS assets"
		task :css do
			STYLESHEETS.each do |css|
				contents = sprockets.find_asset(css).to_s
				LOGGER.debug "File: " + css
				
				File.open(BUILD_DIR.join('stylesheets/', css), 'w') do |f|
					f.write(sass_css(contents))
				end
			end
		end
		
		desc "Minify JS assets"
		task :js do
			JAVASCRIPTS.each do |js|
				contents = sprockets.find_asset(js).to_s
				LOGGER.debug "File: " + js
				
				File.open(BUILD_DIR.join('javascripts/uglifier', js), 'w') do |f|
					f.write(uglify_js(contents))
				end
				File.open(BUILD_DIR.join('javascripts/closure', js), 'w') do |f|
					f.write(closure_js(contents))
				end
			end
		end
	end

end



# Different Javascript compression choices

def uglify_js(js)
  require 'uglifier'
	compressed_js = Uglifier.compile(js)

  LOGGER.debug "uglifier: " + js.length.to_s + ' => ' + compressed_js.length.to_s
  return compressed_js
end

def closure_js(js)
  require 'closure-compiler'
	compiler = Closure::Compiler.new(:compilation_level => 'ADVANCED_OPTIMIZATIONS')
	compressed_js = compiler.compile(js)

  LOGGER.debug "closure: " + js.length.to_s + ' => ' + compressed_js.length.to_s
  return compressed_js
end

# Different general minify choices

#def yuicompressor(file)
#    JAR = "/Users/blanders/MyDocs/Library/yuicompressor.jar"
#  
#  def minify(files)
#    files.each do |file|
#      next if file =~ /\.min\.(js|css)/
#      
#      minfile = file.sub(/\.js$/, ".min.js").sub(/\.css$/, ".min.css")
# 
#      cmd = "java -jar #{JAR} #{file} -o #{minfile}"
#      puts cmd
#      ret = system(cmd)
#      raise "Minification failed for #{file}" if !ret
#    end
#end

def sass_css(css)
	require 'sass'
	engine = Sass::Engine.new css, :syntax => :scss, :style => :compressed
	return engine.to_css
end
