module.exports = (grunt) ->
  require("load-grunt-tasks") grunt
  require('time-grunt') grunt

  collapse = require('bundle-collapser/plugin')

  dimensions = grunt.file.expand("src/*.json").map((json) -> json.match(/\/(.*?).json$/)[1])
  adTasks = dimensions.map (dim) ->
    render = {}
    render["ad_#{dim}"] =
      files: [
        data: "<%= config.sourceDir %>/#{dim}.json"
        template: "<%= config.sourceDir %>/mustache/index.mustache"
        dest: "<%= config.destinationDir %>/#{dim}/index.html"
      ]

    copy = {}
    copy["assets_#{dim}"] =
      files: [
        expand: true
        flatten: true
        src: "<%= config.sourceDir %>/assets/*"
        dest: "<%= config.destinationDir %>/#{dim}/assets"
        filter: 'isFile'
      ]
    copy["gen_#{dim}"] =
      files: [
        expand: true
        flatten: true
        src: "<%= config.destinationDir %>/**/*.min.*"
        dest: "<%= config.destinationDir %>/#{dim}"
        filter: 'isFile'
      ]
    copy["manifest_#{dim}"] =
      files: [
        src: "<%= config.sourceDir %>/#{dim}.json"
        dest: "<%= config.destinationDir %>/#{dim}/manifest.json"
        filter: 'isFile'
      ]

    compress = {}
    compress["zip_#{dim}"] =
      options:
        archive: "<%= config.destinationDir %>/#{dim}.zip"
      files: [
        expand: true
        src: ["#{dim}/**"]
        cwd: "<%= config.destinationDir %>/"
      ]

    {
      mustache_render: render
      copy: copy
      compress: compress
    }

  grunt.initConfig
    config:
      sourceDir: "src"
      destinationDir: "build"

    bower_concat:
      all:
        dest: "<%= config.destinationDir %>/js/bower.js"

    browserify:
      options:
        transform: ['coffeeify']
        plugin: [collapse]
      ad:
        files: [
          src: ["<%= config.sourceDir %>/coffeescript/Main.coffee"]
          dest: "<%= config.destinationDir %>/js/ad.js"
        ]

    uglify:
      bower:
        options:
          mangle: true
          compress: {}
        files:
          "<%= config.destinationDir %>/js/ad.min.js": ["<%= config.destinationDir %>/js/bower.js", "<%= config.destinationDir %>/js/ad.js"]

    less:
      development:
        options:
          paths: ["<%= config.sourceDir %>/less", "bower_components"]
        files:
          "<%= config.destinationDir %>/css/ad.css": "<%= config.sourceDir %>/less/ad.less"

    cssmin:
      target:
        files: [
          expand: true
          cwd: "<%= config.destinationDir %>/css"
          src: ["*.css", "!*.min.css"]
          dest: "<%= config.destinationDir %>/css"
          ext: ".min.css"
        ]

    connect:
      options:
        port: 9010,
        hostname: "*"
        livereload: 35729
      livereload:
        options:
          base: ["./build"]

    watch:
      coffee:
        files: [
          "<%= config.sourceDir %>/**/*.coffee"
          "<%= config.sourceDir %>/**/*.js"
        ]
        tasks: ["browserify", "uglify:bower", "copy"]
        livereload: true
      mustache:
        files: [
          "<%= config.sourceDir %>/**/*.json",
          "<%= config.sourceDir %>/**/*.mustache"
        ]
        tasks: ["mustache_render", "copy"]
        livereload: true
      less:
        files: "<%= config.sourceDir %>/**/*.less"
        tasks: ["less", "cssmin", "copy"]
        livereload: true
      copy:
        files: "<%= config.sourceDir %>/assets/*"
        tasks: ["copy"]
        livereload: true
      livereload:
        options:
          livereload: "<%= connect.options.livereload %>"
        files: ["<%= config.destinationDir %>/**/*.{html,js,jpg,gif,png,swf}"]

  adTasks.forEach grunt.config.merge

  grunt.registerTask 'default', [
    'bower_concat'
    'browserify'
    'uglify:bower'
    'mustache_render'
    'less'
    'cssmin'
    'copy'
    'compress'
  ]

  grunt.registerTask "serve", (target) ->
    grunt.task.run [
      "default"
      "connect:livereload"
      "watch"
    ]

  return
