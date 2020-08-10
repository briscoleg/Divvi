//
//  CircularGraph.swift
//  Balance
//
//  Created by Bo on 8/10/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import UIKit

class CircularGraph: UIView {
    
    let trackLayer = CAShapeLayer()
    let progressLayer = CAShapeLayer()
    
    var percentageValue = CGFloat()
    
    var lineWidth: CGFloat = 15 { didSet { updatePath() } }
    
    var trackLayerFillColor: UIColor = .clear { didSet { trackLayer.fillColor = trackLayerFillColor.cgColor } }
    var progressLayerFillColor: UIColor = .clear { didSet { progressLayer.fillColor = progressLayerFillColor.cgColor } }
    
    var trackLayerStrokeColor: UIColor = .lightGray { didSet { trackLayer.strokeColor = trackLayerStrokeColor.cgColor } }
    var progressLayerStrokeColor: UIColor = .red { didSet { progressLayer.strokeColor = progressLayerStrokeColor.cgColor } }
    
    var trackLayerStrokeStart: CGFloat = 0 { didSet { trackLayer.strokeStart = trackLayerStrokeStart } }
    var progressLayerStrokeStart: CGFloat = 0 { didSet { progressLayer.strokeStart = progressLayerStrokeStart } }
    
    var trackLayerStrokeEnd: CGFloat = 1 { didSet { trackLayer.strokeEnd = trackLayerStrokeEnd } }
    var progressLayerStrokeEnd: CGFloat = 1 { didSet { CATransaction.begin()
    CATransaction.setDisableActions(true)
    progressLayer.strokeEnd = progressLayerStrokeEnd
    CATransaction.commit() } }
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      configure()
    }

    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      configure()
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      updatePath()
    }
    
    func configure() {
        
        trackLayer.strokeColor = trackLayerStrokeColor.cgColor
        trackLayer.fillColor = trackLayerFillColor.cgColor
        trackLayer.strokeStart = trackLayerStrokeStart
        trackLayer.strokeEnd = trackLayerStrokeEnd
        
        progressLayer.strokeColor = progressLayerStrokeColor.cgColor
        progressLayer.fillColor = progressLayerFillColor.cgColor
        progressLayer.strokeStart = progressLayerStrokeStart
        progressLayer.strokeEnd = progressLayerStrokeEnd
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        
    }
    
    func updatePath() {
      //The actual calculation for the circular graph
      let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
      let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
      let circularPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)

      trackLayer.path = circularPath.cgPath
      trackLayer.lineWidth = lineWidth

      progressLayer.path = circularPath.cgPath
      progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round

      //Set the frame in order to rotate the outer circular paths to start at 12 o'clock
      trackLayer.transform = CATransform3DIdentity
      trackLayer.frame = bounds
      trackLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)

      progressLayer.transform = CATransform3DIdentity
      progressLayer.frame = bounds
      progressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
    }
    
    }

class CustomCell: UICollectionViewCell {

  let graph: CircularGraph = {
    let graph = CircularGraph()
    graph.translatesAutoresizingMaskIntoConstraints = false
    return graph
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white

    addSubview(graph)
    graph.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    graph.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    graph.heightAnchor.constraint(equalToConstant: 100).isActive = true
    graph.widthAnchor.constraint(equalToConstant: 100).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
