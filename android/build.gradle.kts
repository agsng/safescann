buildscript {
    extra.apply {
        set("ndkVersion", "27.0.12077973")
    }
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.1") // Updated to latest stable
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
        classpath("com.google.gms:google-services:4.4.0")
    }
}

tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}