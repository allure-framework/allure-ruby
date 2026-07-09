export default {
  name: "Allure Ruby",
  output: "./out/allure-report",
  plugins: {
    testops: {
      options: {
        launchName: `Allure Ruby GitHub actions run (${new Date().toISOString()})`,
      },
    },
  },
};
