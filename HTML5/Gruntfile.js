/*global module*/
module.exports = function (grunt) {
    "use strict";
    var sourceFiles, unitTestFiles, config;
    //  order is important
    sourceFiles = [
        //lib
        //'src/lib/lz-string.min.js',
        'src/lib/base64.js',
        //api
        'src/api/network.js',

        //util
        'src/util/asset.js',
        'src/util/input.js',
        'src/util/util.js',
        //'src/lib/thcanvas.js',


        //UI
        'src/ui/base.js',
        'src/ui/view.js',
        'src/ui/control.js',
        'src/ui/context.js',

        //main
        'src/main.js',
        'src/launch.js',
        'src/game_scene.js',

        //model
        'src/model/GameResult.js',
        'src/model/Option.js',
        'src/model/OptionSet.js',
        'src/model/Question.js',
        'src/model/QuestionResult.js',
        'src/model/THUser.js',
        'src/model/Game.js',

        //conf
        'src/conf.js'

    ];
    unitTestFiles = [];
    // Project configuration.

    config = {
        pkg: grunt.file.readJSON('package.json'),
        min: {
            dist: {
                src: sourceFiles,
                dest: 'dist/mg1-html-v<%= pkg.version %>.js'
            }
        },
        concat: {
            options: {
                separator: '\n\n\n'
            },
            source: {
                src: sourceFiles,
                dest: 'dist/mg1-html-v<%= pkg.version %>.js'
            },
            test: {
                src: unitTestFiles,
                dest: 'tests/js/unitTests.js'
            }
        },
        replace: {
            dev: {
                options: {
                    variables: {
                        version: '<%= pkg.version %>',
                        date: '<%= grunt.template.today("yyyy-mm-dd") %>'
                    },
                    prefix: '@@'
                },
                files: [{
                    src: ['dist/mg1-html-v<%= pkg.version %>.js'],
                    dest: 'dist/mg1-html-v<%= pkg.version %>.js'
                }]
            },
            prod: {
                options: {
                    variables: {
                        version: '<%= pkg.version %>'
                    },
                    prefix: '@@'
                },
                files: [{
                    src: ['dist/mg1-html-Global-v<%= pkg.version %>.min.js'],
                    dest: 'dist/mg1-html-Global-v<%= pkg.version %>.min.js'
                }]
            }
        },
        uglify: {
            options: {
                banner: '/*! <%= pkg.name %> v<%= pkg.version %> <%= grunt.template.today("yyyy-mm-dd") %> http://www.tradehero.mobi by TradeHero */\n',
                mangle: {
                    except: ['jQuery', 'Backbone', 'UI']
                },
                sourceMap: false,
                ASCIIOnly: false
            },
            build: {
                files: {
                    'dist/mg1-html-v<%= pkg.version %>.min.js': 'dist/mg1-html-v<%= pkg.version %>.js'
                }
            }
        },
        clean: {
            build: ['dist/*']
        },
        jshint: {
            options: {
                laxbreak: true
            },
            all: ['src/**/*.js']
        },
        strip: {
            dev: {
                src: 'dist/mg1-html-v<%= pkg.version %>.js',
                dest: 'dist/mg1-html-v<%= pkg.version %>.js',
                options: {
                    nodes: ['console.log', 'debug']
                }
            },
            prod: {
                src: 'dist/mg1-html-v<%= pkg.version %>.min.js',
                dest: 'dist/mg1-html-v<%= pkg.version %>.min.js',
                options: {
                    nodes: ['console.log', 'debug']
                }
            }
        },
        connect: {
            server: {
                options: {
                    port: 8000,
                    keepalive: true
                }
            }
        }
    };
    for (var n = 0; n < sourceFiles.length; n++) {
        var inputFile = sourceFiles[n];
        var className = (inputFile.match(/[-_\w]+[.][\w]+$/i)[0]).replace('.js', '');
        var outputFile = 'dist/mg1-html-' + className + '-v<%= pkg.version %>.min.js';
        config.uglify.build.files[outputFile] = [inputFile];
    }
    grunt.initConfig(config);
    // Load plugins
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-replace');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-strip');
    grunt.loadNpmTasks('grunt-yui-compressor');
    grunt.loadNpmTasks('grunt-contrib-connect');
    // Tasks
    grunt.registerTask('dev', ['clean', 'concat:source', 'replace:dev']);
    grunt.registerTask('prod', ['clean', 'concat:source', 'replace:dev', 'uglify', 'replace:prod', 'strip:dev', 'strip:prod']);
    grunt.registerTask('test', ['concat:test']);
    grunt.registerTask('hint', ['clean', 'concat:source', 'replace:dev', 'jshint']);
};