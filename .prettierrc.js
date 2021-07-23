module.exports = {
  overrides: [
    {
      files: "*.sol",
      options: {
        bracketSpacing: false,
        printWidth: 145,
        tabWidth: 2,
        useTabs: false,
        singleQuote: false,
        explicitTypes: "always",
      },
    },
    {
      files: "*.ts",
      options: {
        printWidth: 145,
        semi: true,
        tabWidth: 2,
        singleQuote: false,
        trailingComma: "all",
      },
    },
  ],
};
