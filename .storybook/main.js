module.exports = {
  addons: [],
  framework: '@storybook/react',
  stories: ['../output/Story.*/index.js'],
  webpackFinal: async (config) => {
    // Make whatever fine-grained changes you need
    // Return the altered config
    return config
  }
}
