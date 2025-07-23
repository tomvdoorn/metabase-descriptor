export default function HomePage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Metabase Description Generator
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            AI-powered question description generator with visual tree interface
          </p>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-md border">
            <h2 className="text-xl font-semibold mb-3">Tree View</h2>
            <p className="text-gray-600">
              Navigate your Metabase collections with an intuitive tree interface
            </p>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow-md border">
            <h2 className="text-xl font-semibold mb-3">AI Generation</h2>
            <p className="text-gray-600">
              Generate contextual descriptions using advanced AI models
            </p>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow-md border">
            <h2 className="text-xl font-semibold mb-3">Bulk Operations</h2>
            <p className="text-gray-600">
              Process multiple questions efficiently with batch operations
            </p>
          </div>
        </div>
        
        <div className="mt-12 text-center">
          <p className="text-gray-500">
            Project structure initialized. Ready for development.
          </p>
        </div>
      </div>
    </div>
  )
}