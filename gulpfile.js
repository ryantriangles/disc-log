const gulp = require('gulp');
const elm = require('gulp-elm');
const flatten = require('gulp-flatten');

gulp.task('default', ['elm', 'html']);

gulp.task('elm', _ => {
  return gulp.src('src/frontend/Main.elm')
             .pipe(elm())
             .pipe(gulp.dest('build/'));
});

gulp.task('html', _ => {
	return gulp.src(['./src/frontend/index.html', './src/frontend/styles.css'])
	           .pipe(flatten())
	           .pipe(gulp.dest('./build'));
});
