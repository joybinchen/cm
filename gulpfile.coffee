###
gulpfile.coffee
Copyright (C) 2015 ender xu <xuender@gmail.com>

Distributed under terms of the MIT license.
###
gulp = require 'gulp'
clean = require 'gulp-clean'
sass = require 'gulp-sass'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
usemin = require 'gulp-usemin'
uglify = require 'gulp-uglify'
minifyCss = require 'gulp-minify-css'
minifyHtml = require 'gulp-minify-html'
rev = require 'gulp-rev'
manifest = require 'gulp-chrome-manifest'
zip = require 'gulp-zip'
livereload = require 'gulp-livereload'
runSequence = require 'gulp-run-sequence'
karma = require('karma').server
jeditor = require 'gulp-json-editor'

Package = require './package.json'

gulp.task('clean', ->
  gulp.src([
    'dist'
  ], {read: false})
    .pipe(clean())
)

gulp.task('usemin', ->
  for s in ['about.html']
    gulp.src("src/extension/options/#{s}")
      .pipe(usemin({
        #css: minifyCss()
        #html: [minifyHtml({empty: true})],
        #js: uglify()
      }))
        .pipe(gulp.dest('dist/extension/options'))
  for s in ['options.html', 'popup.html']
    gulp.src("src/extension/#{s}")
      .pipe(usemin({
        #css: [minifyCss()],
        #css: [rev()],
        #html: [minifyHtml({empty: true})],
        #js: [uglify()],
      }))
        .pipe(gulp.dest('dist/extension'))
)

gulp.task('sass', ->
  gulp.src(['src/extension/popup/popup.sass', 'src/extension/options/options.sass'])
    .pipe(sass(
      errLogToConsole: true
      indentedSyntax: true
    ))
    .pipe(gulp.dest('src/extension/css'))
)

gulp.task('copy', ->
  gulp.src([
    'src/extension/lib/oauth/chrome_ex_oauth.min.js'
    'src/extension/lib/*.min.js'
    'src/extension/lib/*.min.js'
  ])
    .pipe(gulp.dest('dist/lib'))
  gulp.src([
    'src/extension/*.json'
  ])
    .pipe(gulp.dest('dist/extension'))
  gulp.src([
    'src/extension/_locales/**'
  ])
    .pipe(gulp.dest('dist/extension/_locales'))
  gulp.src([
    'src/extension/img/**'
  ])
    .pipe(gulp.dest('dist/extension/img'))
  gulp.src([
    'src/extension/lib/bootstrap/fonts/*'
  ])
    .pipe(gulp.dest('dist/extension/fonts'))
  gulp.src([
    'src/extension/scripts/**'
  ])
    .pipe(gulp.dest('dist/extension/scripts'))
)

gulp.task('concat', ->
  gulp.src([
    'src/extension/lib/js-utils/js/ionic.min.js'
    'src/extension/scripts/chrome_ex_oauth.min.js'
    'src/extension/lib/js-utils/js/chrome.min.js'
    'src/extension/lib/js-utils/js/js-utils.min.js'
    'src/extension/scripts/qrcode.min.js'
  ])
    .pipe(concat('bg_lib.js'))
    .pipe(gulp.dest('src/extension/js'))
)

gulp.task('test', ->
  karma.start(
    configFile: __dirname + '/karma.conf.js',
    singleRun: true
  )
)

gulp.task('coffee', ->
  gulp.src([
    'src/extension/scripts/analytics.coffee'
    'src/extension/popup/popup.coffee'
    'src/extension/popup/popupCtrl.coffee'
    'src/extension/scripts/utilDirectives.coffee'
  ])
    .pipe(coffee({bare:true}))
    .pipe(concat('popup.js'))
    .pipe(gulp.dest('src/extension/js'))
  gulp.src([
    'src/extension/scripts/analytics.coffee'
    'src/extension/options/chosen.coffee'
    'src/extension/options/options.coffee'
    'src/extension/options/optionsCtrl.coffee'
    'src/extension/options/menuCtrl.coffee'
    'src/extension/options/menusCtrl.coffee'
    'src/extension/options/putCtrl.coffee'
    'src/extension/options/editCtrl.coffee'
    'src/extension/options/putCtrl.coffee'
    'src/extension/options/aboutCtrl.coffee'
    'src/extension/options/settingsCtrl.coffee'
    'src/extension/scripts/utilDirectives.coffee'
    'src/extension/options/menuService.coffee'
    'src/extension/options/dialogService.coffee'
    'src/extension/options/i18nService.coffee'
    'src/extension/options/directives.coffee'
  ])
    .pipe(coffee({bare:true}))
    .pipe(concat('options.js'))
    .pipe(gulp.dest('src/extension/js'))
  gulp.src([
    'src/extension/i18n/*.coffee'
  ])
    .pipe(coffee({bare:true}))
    .pipe(concat('i18n.js'))
    .pipe(gulp.dest('src/extension/js'))
  gulp.src([
    'src/extension/background/code.coffee'
    'src/extension/background/tools.coffee'
    'src/extension/background/background.coffee'
    'src/extension/scripts/analytics.coffee'
    #'src/extension/background/chromereload.coffee' # 正式发布需要删除这行
  ])
    .pipe(coffee({bare:true}))
    .pipe(concat('background.js'))
    .pipe(gulp.dest('src/extension/js'))
)

gulp.task('manifest', ->
  gulp.src('src/extension/manifest.json')
    .pipe(jeditor((json)->
      json.version = Package.version
      json
    ))
    .pipe(manifest(
      buildnumber: true,
      exclude: [
        'key'
      ],
      #background:
      #  target: 'js/background.js',
      #  exclude: [
      #    'scripts/chromereload.js'
      #  ]
    ))
    .pipe(gulp.dest('dist/extension'))
)

gulp.task('zip', ->
  gulp.src('dist/extension/**')
    .pipe(zip("#{Package.name}-#{Package.version}.zip"))
    .pipe(gulp.dest('dist'))
)

gulp.task('watch', ->
  livereload.listen()
  gulp.watch(['src/**/*.scss', 'src/**/*.sass'], ['sass'])
  gulp.watch('src/**/*.coffee', ['coffee'])
  gulp.watch(['src/**/*.json', 'src/**/*.png'], ['copy'])
  gulp.watch('src/**/*.html', ['usemin'])
  #gulp.watch("src/**/*.html").on 'change', livereload.changed
  karma.start(
    configFile: __dirname + '/karma.conf.js',
  )
)

gulp.task('dev', (cb)->
  runSequence('clean', ['concat', 'coffee', 'sass', 'copy'], 'usemin', cb)
)

gulp.task('dist', (cb)->
  runSequence('dev','manifest', 'zip', cb)
)

gulp.task('deploy', (cb)->
  runSequence('bump','dist', cb)
)

gulp.task('default', ['dev'])

