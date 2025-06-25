buildscript {
    extra.apply {
        set("ndkVersion", "27.0.12077973")  // Explicit NDK version for Firebase
    }
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
        classpath("com.google.gms:google-services:4.4.0")  // Firebase classpath
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory configuration (simplified)
rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}