export default {
  name: "Allure Ruby",
  output: "./out/allure-report",
  resultsDir: "*/reports/allure-results/**",
  plugins: {
    testops: {
      options: {
        launchName: `Allure Ruby GitHub actions run (${new Date().toISOString()})`,
      },
    },
  },
};
