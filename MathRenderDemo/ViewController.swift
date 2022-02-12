//
//  ViewController.swift
//  MathRenderDemo
//
//  Created by Mike Griebling on 2022-02-11.
//

import UIKit
import MathRender

class FontPickerDelegate : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var fontNames = ["Latin Modern Math", "TeX Gyre Termes", "XITS Math"]
    weak var controller : ViewController!
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.fontNames.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.fontNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.controller.fontField.text = self.fontNames[row]
        self.controller.fontField.resignFirstResponder()
        switch row {
            case 0: self.controller.latinButtonPressed()
            case 1: self.controller.termesButtonPressed()
            case 2: self.controller.xitsButtonPressed()
            default: break
        }
    }
    
}

class ColorPickerDelegate : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var colors = [UIColor.black, .blue, .red, .green]
    weak var controller : ViewController!
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.colors.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.backgroundColor = self.colors[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let color = self.colors[row]
        self.controller.colorField.backgroundColor = color
        self.controller.changeColor(color)
        self.controller.colorField.resignFirstResponder()
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fontField: UITextField!
    @IBOutlet weak var colorField: UITextField!
    @IBOutlet weak var latexField: UITextField!
    @IBOutlet weak var mathLabel: MTMathUILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pickerDelegate : FontPickerDelegate!
    var colorPickerDelegate: ColorPickerDelegate!
    var demoLabels = [MTMathUILabel]()
    var labels = [MTMathUILabel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Set up the font picker
        self.pickerDelegate = FontPickerDelegate()
        self.pickerDelegate.controller = self
        var picker = UIPickerView()
        picker.delegate = self.pickerDelegate
        picker.dataSource = self.pickerDelegate
        self.fontField.inputView = picker
        self.fontField.delegate = self
        self.fontField.text = self.pickerDelegate.fontNames[0]
        
        // Set up the color picker
        self.colorPickerDelegate = ColorPickerDelegate()
        self.pickerDelegate.controller = self
        picker = UIPickerView()
        picker.delegate = self.colorPickerDelegate
        picker.dataSource = self.colorPickerDelegate
        self.colorField.inputView = picker
        self.colorField.delegate = self
        
        self.latexField.delegate = self

        let contentView = UIView()
        self.addFullSizeView(contentView, to: scrollView)
        self.setEqualWidths(contentView, view2: scrollView)
        self.setHeight(4350, for: contentView)
        
        // Demo formulae
        // Quadratic formula
        demoLabels.append(createMathLabel("\\text{ваш вопрос: }x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}", height: 60))
        addLabelAsSubview(demoLabels[0], to: contentView)
        demoLabels[0].fontSize = 15
        // First label so set the height from the top
        let view = demoLabels[0]
        let views = ["view": view]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[view]", options: .alignAllCenterX, metrics: nil, views: views))
        
        // make some more examples
        demoLabels.append(createMathLabel("\\color{#ff3399}{(a_1+a_2)^2}=a_1^2+2a_1a_2+a_2^2", height: 40))
        demoLabels.append(createMathLabel("\\cos(\\theta + \\varphi) = \\cos(\\theta)\\cos(\\varphi) - \\sin(\\theta)\\sin(\\varphi)", height:40))
        demoLabels.append(createMathLabel("\\frac{1}{\\left(\\sqrt{\\phi \\sqrt{5}}-\\phi\\right) e^{\\frac25 \\pi}} " +
                                          "= 1+\\frac{e^{-2\\pi}} {1 +\\frac{e^{-4\\pi}} {1+\\frac{e^{-6\\pi}} {1+\\frac{e^{-8\\pi}} {1+\\cdots} } } }", height:80))
        demoLabels.append(createMathLabel("\\sigma = \\sqrt{\\frac{1}{N}\\sum_{i=1}^N (x_i - \\mu)^2}", height:60))
        demoLabels.append(createMathLabel("\\neg(P\\land Q) \\iff (\\neg P)\\lor(\\neg Q)", height:40))
        demoLabels.append(createMathLabel("\\log_b(x) = \\frac{\\log_a(x)}{\\log_a(b)}", height:40))
        demoLabels.append(createMathLabel("\\lim_{x\\to\\infty}\\left(1 + \\frac{k}{x}\\right)^x = e^k", height:40))
        demoLabels.append(createMathLabel("\\int_{-\\infty}^\\infty \\! e^{-x^2} dx = \\sqrt{\\pi}", height:40))
        demoLabels.append(createMathLabel("\\frac 1 n \\sum_{i=1}^{n}x_i \\geq \\sqrt[n]{\\prod_{i=1}^{n}x_i}", height:60))
        demoLabels.append(createMathLabel("f^{(n)}(z_0) = \\frac{n!}{2\\pi i}\\oint_\\gamma\\frac{f(z)}{(z-z_0)^{n+1}}\\,dz", height:40))
        
        for i in 1..<demoLabels.count {
            demoLabels[i].fontSize = 15
            addLabel(withIndex: i, inArray: demoLabels, toView: contentView)
        }
        
        let lastDemoLabel = demoLabels.last!
        
        // make some text formulae
        labels.append(createMathLabel("3+2-5 = 0", height:40))
        labels[0].backgroundColor = UIColor(hue:0.15, saturation:0.2, brightness:1.0, alpha:1.0)
        addLabelAsSubview(labels[0], to:contentView)
        setVerticalGap(30, between:lastDemoLabel, and:labels[0])

        // Infix and prefix Operators
        labels.append(createMathLabel("12+-3 > +14", height:40))
        labels[1].backgroundColor = UIColor(hue:0.15, saturation:0.2, brightness:1.0, alpha:1.0)
        labels[1].textAlignment = .center

        // Punct, parens
        labels.append(createMathLabel("(-3-5=-8, -6-7=-13)", height:40))

        // Latex commands
        labels.append(createMathLabel("5\\times(-2 \\div 1) = -10", height:40))
        labels[3].backgroundColor = UIColor(hue:0.15, saturation:0.2, brightness:1.0, alpha:1.0)
        labels[3].textAlignment = .right;
        labels[3].contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20);

        labels.append(createMathLabel("-h - (5xy+2) = z", height:40))
        
        for i in 1..<labels.count {
            addLabel(withIndex: i, inArray: labels, toView: contentView)
        }
    }
    
    func addLabel(withIndex idx:Int, inArray array: [MTMathUILabel], toView contentView: UIView) {
        guard idx > 0 else { assertionFailure("Index should be greater than 0. For the first label add manually."); return }
        self.addLabelAsSubview(array[idx], to: contentView)
        self.setVerticalGap(10, between: array[idx-1], and: array[idx])
    }
    
    func createMathLabel(_ latex:String, height: CGFloat) -> MTMathUILabel {
        let label = MTMathUILabel()
        self.setHeight(height, for: label)
        label.latex = latex
        return label
    }
    
    // MARK: - Constraints
    
    func addFullSizeView(_ view: UIView, to parent:UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let views = ["view":view]
        parent.addSubview(view)
        parent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: .alignAllCenterY, metrics: nil, views: views))
        parent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: .alignAllCenterX, metrics: nil, views: views))
    }
    
    func setHeight(_ height: CGFloat, for view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        constraint.isActive = true
    }
    
    func setEqualWidths(_ view1:UIView, view2:UIView) {
        let constraint = NSLayoutConstraint(item: view1, attribute: .width, relatedBy: .equal, toItem: view2, attribute: .width, multiplier: 1, constant: 0)
        constraint.isActive = true
    }
    
    func addLabelAsSubview(_ label: UIView, to parent:UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        let views = ["label":label]
        parent.addSubview(label)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[label]-(10)-|", options: .alignAllCenterY, metrics: nil, views: views))
    }
    
    func setVerticalGap(_ gap: CGFloat, between view1: UIView, and view2: UIView) {
        let constraint = NSLayoutConstraint(item: view2, attribute: .top, relatedBy: .equal, toItem: view1, attribute: .bottom, multiplier: 1, constant: gap)
        constraint.isActive = true
    }
    
    
    // MARK: - Buttons
    
    func latinButtonPressed() {
        for label in demoLabels {
            label.font = MTFontManager().latinModernFont(withSize: label.font.fontSize)
        }
        for label in labels {
            label.font = MTFontManager().latinModernFont(withSize: label.font.fontSize)
        }
    }
    
    func termesButtonPressed() {
        for label in demoLabels {
            label.font = MTFontManager().termesFont(withSize: label.font.fontSize)
        }
        for label in labels {
            label.font = MTFontManager().termesFont(withSize: label.font.fontSize)
        }
    }
    
    func xitsButtonPressed() {
        for label in demoLabels {
            label.font = MTFontManager().xitsFont(withSize: label.font.fontSize)
        }
        for label in labels {
            label.font = MTFontManager().xitsFont(withSize: label.font.fontSize)
        }
    }
    
    func changeColor(_ color: UIColor) {
        for label in demoLabels {
            label.textColor = color
        }
        for label in labels {
            label.textColor = color
        }
    }
    
    
    // MARK: - Text Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.latexField {
            textField.resignFirstResponder()
            self.mathLabel.latex = self.latexField.text
            return true
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.latexField {
            return true
        }
        return false
    }


}

