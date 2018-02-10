#!/usr/bin/env groovy

def app
String registry = 'http://10.0.0.5:5000'
String image_name = 'simple-go-helloworld'

node {
  docker.image('nimmis/alpine-golang').inside('-u root') {
    // Preparing container
    stage ('System requirenments') {
      // installing system required packages
      sh '''
        apk add --update libltdl git make
      '''
      // symlink to GOPATH and move to application workspace
      sh '''
        mkdir -p $GOPATH/src
        ln -s $WORKSPACE $GOPATH/src
        cd $GOPATH/src/simple-go-helloworld
      '''
    }
    
    // Run code testing
    stage('Test') {
      sh '''
        make test
      '''
    }
    
    // build binary
    stage('Build') {
      // build the code
      sh '''
        make build
      '''
    }
    
    // deploy
    stage('Deploy') {
      // build image
      docker.withRegistry(registry) {
        String short_commit = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
        def image = docker.build("${image_name}:${short_commit}")
        image.push()
        image.push('latest')
      }
    }
  }  
}