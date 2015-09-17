var babelify      = require("babelify")
var browserify    = require("browserify")
var connect       = require("gulp-connect")
var es            = require('event-stream')
var mustache      = require('gulp-mustache')
var cssmin        = require("gulp-cssmin")
var gulp          = require("gulp")
var notify        = require("gulp-notify")
var rename        = require("gulp-rename")
var path          = require("path")
var prefix        = require("gulp-autoprefixer")
var sass          = require("gulp-sass")
var source        = require("vinyl-source-stream")
var watch         = require("gulp-watch")
var zip           = require("gulp-zip")
var uglify        = require('gulp-uglify')
var buffer        = require('vinyl-buffer')

require('es6-promise').polyfill()

var config = {
  sassDir: "src/sass",
  jsDir: "src/js",
  mustacheDir: "src/mustache",
  manifestDir: "src/manifest",
  sizes: ["320x240"]
}

gulp.task("js", function() {
  return browserify({entries: path.join(config.jsDir, "Main.js")})
    .transform(babelify)
    .bundle()
    .on("error", notify.onError())
    .pipe(source("ad.js"))
    .pipe(buffer())
    .pipe(uglify())
    .pipe(gulp.dest("www"))
    .pipe(notify({message: "Generated: <%= file.relative %>"}))
})

gulp.task("css", function() {
  return gulp.src(path.join(config.sassDir, "**/*.scss"))
    .pipe(sass({includePaths: [config.sassDir]}).on("error", notify.onError()))
    .pipe(prefix("> 1%"))
    .pipe(cssmin({keepSpecialComments: 0}))
    .pipe(gulp.dest("www"))
    .pipe(notify({message: "Generated: <%= file.relative %>"}));
})

gulp.task("watch", function() {
  gulp.watch(path.join(config.sassDir, "**/*.scss"), ["build"])
  gulp.watch(path.join(config.jsDir, "**/*.js"), ["build"])
  gulp.watch(path.join(config.mustacheDir, "**/*.mustache"), ["build"])
})

gulp.task("server", function() {
  return connect.server({
    root: "www",
    livereload: true
  })
})

config.sizes.forEach(function(size) {
  gulp.task(size, ["js", "css"], function() {
    var manifest = require("./src/manifest/" + size + ".json")

    var assetsTask =
      gulp.src([
        "www/ad.js",
        "www/ad.css"],
      {base: "www"})
        .pipe(gulp.dest("www/" + size))
        .pipe(connect.reload())

    var manifestTask =
      gulp.src("src/manifest/" + size + ".json")
        .pipe(rename("manifest.json"))
        .pipe(gulp.dest("www/" + size))
        .pipe(connect.reload())

    var mustacheTask =
      gulp.src("src/mustache/index.mustache")
        .pipe(mustache(manifest, {extension: ".html"}))
        .pipe(gulp.dest("www/" + size))
        .pipe(connect.reload())

    return es.merge(assetsTask, manifestTask, mustacheTask)
  })
})

gulp.task("build", config.sizes)
gulp.task("default", ["build", "watch", "server"])
