

allprojects {
    repositories {
        mavenLocal()
        google()
        mavenCentral()
        maven {
            url = uri("https://jfrog.anythinktech.com/artifactory/overseas_sdk")
        }

        //Maio
        maven {
            url = uri("https://imobile-maio.github.io/maven")
        }

        //Nend
//        maven {
//            url = uri("https://fan-adn.github.io/nendSDK-Android-lib/library")
//        }

        //YSO Network
//        maven {
//            url = uri("https://ysonetwork.s3.eu-west-3.amazonaws.com/sdk/android")
//        }
//
//        //PubMatic
//        maven {
//            url = uri("https://repo.pubmatic.com/artifactory/public-repos")
//        }

        //Ironsource
        maven {
            url = uri("https://android-sdk.is.com/")
        }

//        //Tapjoy
//        maven {
//            url = uri("https://sdk.tapjoy.com/")
//        }

        //Pubnative
//        maven {
//            url = uri("https://verve.jfrog.io/artifactory/verve-gradle-release")
//        }
//
//
//
//        maven {
//            url = uri("https://bitbucket.org/sdkcenter/sdkcenter/raw/release")
//        }

//        //Smaato
//        maven {
//            url = uri("https://s3.amazonaws.com/smaato-sdk-releases/")
//        }

        //Pangle
        maven {
            url = uri("https://artifact.bytedance.com/repository/pangle")
        }

//        //Huawei
//        maven {
//            url = uri("https://developer.huawei.com/repo/")
//        }

        //Mintegral
        maven {
            url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea")
        }

//        //BidMachine
//        maven {
//            url = uri( "https://artifactory.bidmachine.io/bidmachine")
//        }

        //Chartboost
        maven {
            url = uri("https://cboost.jfrog.io/artifactory/chartboost-ads")
        }
        maven {
            url =uri("https://cboost.jfrog.io/artifactory/chartboost-mediation")
        }

        //Ogury
//        maven {
//            url = uri("https://maven.ogury.co")
//        }
//
//        //Appnext
//        maven {
//            url = uri("https://dl.appnext.com")
//        }

        maven {
            url = uri("https://jfrog.anythinktech.com/artifactory/debugger")
        }
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
