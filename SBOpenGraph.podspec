Pod::Spec.new do |s|

    s.name        = 'SBOpenGraph'
    s.version     = '1.0.2'
    s.summary     = 'A lightweight and pure Swift implemented library to parse The Open Graph protocol.'
  
    s.description = <<-DESC
                         SBOpenGraph is a lightweight and pure Swift implemented library to parse The Open Graph protocol.
                         DESC
  
    s.homepage    = 'https://github.com/spirit-jsb/SBOpenGraph'
    
    s.license     = { :type => 'MIT', :file => 'LICENSE' }
    
    s.author      = { 'spirit-jsb' => 'sibo_jian_29903549@163.com' }
    
    s.swift_versions = ['5.0']
    
    s.ios.deployment_target = '11.0'
      
    s.source       = { :git => 'https://github.com/spirit-jsb/SBOpenGraph.git', :tag => s.version }
    s.source_files = ["Sources/**/*.swift"]
    
    s.requires_arc = true
  end
  
