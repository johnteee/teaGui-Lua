set LUAJ=d:\devkit\ufo-master\luaj-3.0-alpha2
java -classpath "%LUAJ%/lib/luaj-jse-3.0-alpha2.jar;%LUAJ%/lib/bcel-5.2.jar" lua -b %*
