allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null) {
            val extension = android as? com.android.build.gradle.BaseExtension
            // This ensures the library has a namespace so the build doesn't fail
            if (extension?.namespace == null) {
                extension?.namespace = project.group.toString()
            }
        }
    }

    // UPDATED: Telling Kotlin to compile using Java 17 to match the Java compiler
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompilationTask<*>>().configureEach {
        compilerOptions {
            if (this is org.jetbrains.kotlin.gradle.dsl.KotlinJvmCompilerOptions) {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17) 
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            val androidExt = extensions.getByName("android") as com.android.build.gradle.BaseExtension
            androidExt.compileSdkVersion(36)
        }
    }
}