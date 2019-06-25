pipeline {
  agent { docker 'ruby:2.6.3' }
  parameters {
    booleanParam(name: 'RELEASE', defaultValue: false, description: 'Perform release?')
  }
  stages {
    stage('Install') {
      steps {
        sh 'gem install bundler -v 2.0.1'
        sh 'bundle install' 
      }
    }
    stage('Lint') {
      steps { sh 'bundle exec rake rubocop' }
    }
    stage('Test') {
      steps { sh 'bundle exec rake test' }
    }
    stage('Release') {
      when { expression { return params.RELEASE } }
      steps {
        withCredentials([string(credentialsId: 'qameta-ci_rubygems', variable: 'GEM_HOST_API_KEY')]) {
          sh  'bundle exec rake release'
        }
      }
    }
  }
  post {
    always { deleteDir() }
    failure {
      slackSend message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} failed (<${env.BUILD_URL}|Open>)",
              color: 'danger', teamDomain: 'qameta', channel: 'allure', tokenCredentialId: 'allure-channel'
    }
  }
}
