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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        label.backgroundColor = self.colors[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let color = self.colors[row]
        controller.changeColor(color)
        controller.colorField.backgroundColor = color
        controller.colorField.resignFirstResponder()
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
        self.colorPickerDelegate.controller = self
        picker = UIPickerView()
        picker.delegate = self.colorPickerDelegate
        picker.dataSource = self.colorPickerDelegate
        self.colorField.inputView = picker
        self.colorField.delegate = self
        
        self.latexField.delegate = self

        let contentView = UIView()
        self.addFullSizeView(contentView, to: scrollView)
        self.setEqualWidths(contentView, view2: scrollView)
        self.setHeight(5100, for: contentView)
        
        // Demo formulae
        // Quadratic formula
        demoLabels.append(createMathLabel("\\text{Quadratic roots: }x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}", height: 60))
        addLabelAsSubview(demoLabels[0], to: contentView)
        demoLabels[0].fontSize = 25
        // First label so set the height from the top
        let view = demoLabels[0]
        let views = ["view": view]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[view]", options: .alignAllCenterX, metrics: nil, views: views))
        
        // make some more examples
        demoLabels.append(createMathLabel("\\color{#ff3399}{(a_1+a_2)^2}=a_1^2+2a_1a_2+a_2^2", height: 50))
        demoLabels.append(createMathLabel("\\cos(\\theta + \\varphi) = \\cos(\\theta)\\cos(\\varphi) - \\sin(\\theta)\\sin(\\varphi)", height:50))
        demoLabels.append(createMathLabel("\\frac{1}{\\left(\\sqrt{\\phi \\sqrt{5}}-\\phi\\right) e^{\\frac25 \\pi}} " +
                                          "= 1+\\frac{e^{-2\\pi}} {1 +\\frac{e^{-4\\pi}} {1+\\frac{e^{-6\\pi}} {1+\\frac{e^{-8\\pi}} {1+\\cdots} } } }", height:100))
        demoLabels.append(createMathLabel("\\sigma = \\sqrt{\\frac{1}{N}\\sum_{i=1}^N (x_i - \\mu)^2}", height:100))
        demoLabels.append(createMathLabel("\\neg(P\\land Q) \\iff (\\neg P)\\lor(\\neg Q)", height:50))
        demoLabels.append(createMathLabel("\\log_b(x) = \\frac{\\log_a(x)}{\\log_a(b)}", height:70))
        demoLabels.append(createMathLabel("\\lim_{x\\to\\infty}\\left(1 + \\frac{k}{x}\\right)^x = e^k", height:70))
        demoLabels.append(createMathLabel("\\int_{-\\infty}^\\infty \\! e^{-x^2} dx = \\sqrt{\\pi}", height:70))
        demoLabels.append(createMathLabel("\\frac 1 n \\sum_{i=1}^{n}x_i \\geq \\sqrt[n]{\\prod_{i=1}^{n}x_i}", height:100))
        demoLabels.append(createMathLabel("f^{(n)}(z_0) = \\frac{n!}{2\\pi i}\\oint_\\gamma\\frac{f(z)}{(z-z_0)^{n+1}}\\,dz", height:70))
        demoLabels.append(createMathLabel("i\\hbar\\frac{\\partial}{\\partial t}\\mathbf\\Psi(\\mathbf{x},t) = " +
                               "-\\frac{\\hbar}{2m}\\nabla^2\\mathbf\\Psi(\\mathbf{x},t) + V(\\mathbf{x})\\mathbf\\Psi(\\mathbf{x},t)", height:60))
        demoLabels.append(createMathLabel("\\left(\\sum_{k=1}^n a_k b_k \\right)^2 \\le \\left(\\sum_{k=1}^n a_k^2\\right)\\left(\\sum_{k=1}^n b_k^2\\right)", height:100))
        demoLabels.append(createMathLabel("{n \\brace k} = \\frac{1}{k!}\\sum_{j=0}^k (-1)^{k-j}\\binom{k}{j}(k-j)^n", height:80))
        demoLabels.append(createMathLabel("f(x) = \\int\\limits_{-\\infty}^\\infty\\!\\hat f(\\xi)\\,e^{2 \\pi i \\xi x}\\,\\mathrm{d}\\xi", height:100))
        demoLabels.append(createMathLabel("\\begin{gather}" +
                                          "\\dot{x} = \\sigma(y-x) \\\\" +
                                          "\\dot{y} = \\rho x - y - xz \\\\" +
                                          "\\dot{z} = -\\beta z + xy" +
                                          "\\end{gather}", height:120))
        demoLabels.append(createMathLabel("\\vec \\bf V_1 \\times \\vec \\bf V_2 =  \\begin{vmatrix}" +
                               "\\hat \\imath &\\hat \\jmath &\\hat k \\\\" +
                               "\\frac{\\partial X}{\\partial u} &  \\frac{\\partial Y}{\\partial u} & 0 \\\\" +
                               "\\frac{\\partial X}{\\partial v} &  \\frac{\\partial Y}{\\partial v} & 0" +
                               "\\end{vmatrix}", height:120))
        demoLabels.append(createMathLabel("\\begin{eqalign}" +
                               "\\nabla \\cdot \\vec{\\bf{E}} & = \\frac {\\rho} {\\varepsilon_0} \\\\" +
                               "\\nabla \\cdot \\vec{\\bf{B}} & = 0 \\\\" +
                               "\\nabla \\times \\vec{\\bf{E}} &= - \\frac{\\partial\\vec{\\bf{B}}}{\\partial t} \\\\" +
                               "\\nabla \\times \\vec{\\bf{B}} & = \\mu_0\\vec{\\bf{J}} + \\mu_0\\varepsilon_0 \\frac{\\partial\\vec{\\bf{E}}}{\\partial t}" +
                               "\\end{eqalign}", height:250))
        demoLabels.append(createMathLabel("\\begin{pmatrix}" +
                               "a & b\\\\ c & d" +
                               "\\end{pmatrix}" +
                               "\\begin{pmatrix}" +
                               "\\alpha & \\beta \\\\ \\gamma & \\delta" +
                               "\\end{pmatrix} = " +
                               "\\begin{pmatrix}" +
                               "a\\alpha + b\\gamma & a\\beta + b \\delta \\\\" +
                               "c\\alpha + d\\gamma & c\\beta + d \\delta " +
                               "\\end{pmatrix}", height:100))
        demoLabels.append(createMathLabel("\\frak Q(\\lambda,\\hat{\\lambda}) = " +
                               "-\\frac{1}{2} \\mathbb P(O \\mid \\lambda ) \\sum_s \\sum_m \\sum_t \\gamma_m^{(s)} (t) +\\\\ " +
                               "\\quad \\left( \\log(2 \\pi ) + \\log \\left| \\cal C_m^{(s)} \\right| + " +
                               "\\left( o_t - \\hat{\\mu}_m^{(s)} \\right) ^T \\cal C_m^{(s)-1} \\right) ", height:160))
        demoLabels.append(createMathLabel("f(x) = \\begin{cases}" +
                               "\\frac{e^x}{2} & x \\geq 0 \\\\" +
                               "1 & x < 0" +
                               "\\end{cases}", height:80))
        demoLabels.append(createMathLabel("\\color{#ff3333}{c}\\color{#9933ff}{o}\\color{#ff0080}{l}+\\color{#99ff33}{\\frac{\\color{#ff99ff}{o}}" + "{\\color{#990099}{r}}}-\\color{#33ffff}{\\sqrt[\\color{#3399ff}{e}]{\\color{#3333ff}{d}}}", height:70))
        
        for i in 1..<demoLabels.count {
            demoLabels[i].fontSize = 25
            addLabel(withIndex: i, inArray: demoLabels, toView: contentView)
        }
        
        let lastDemoLabel = demoLabels.last!
        
        // make some text formulae
        labels.append(createMathLabel("3+2-5 = 0", height:40))
        labels[0].backgroundColor = UIColor(hue:0.15, saturation:0.2, brightness:1.0, alpha:1.0)
        addLabelAsSubview(labels[0], to:contentView)
        setVerticalGap(50, between:lastDemoLabel, and:labels[0])

        // Infix and prefix Operators
        labels.append(createMathLabel("12+-3 > +14", height:40))
        labels[1].backgroundColor = UIColor(hue:0.15, saturation:0.2, brightness:1.0, alpha:1.0)
        labels[1].textAlignment = .center

        // Punct, parens
        labels.append(createMathLabel("(-3-5=-8, -6-7=-13)", height:40))

        // Latex commands
        labels.append(createMathLabel("5\\times(-2 \\div 1) = -10", height:40))
        labels[3].backgroundColor = UIColor(hue:0.15, saturation:0.2, brightness:1.0, alpha:1.0)
        labels[3].textAlignment = .right
        labels[3].contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20);

        labels.append(createMathLabel("-h - (5xy+2) = z", height:40))
        
        // Text mode fraction
        labels.append(createMathLabel("\\frac12x + \\frac{3\\div4}2y = 25", height:60))
        self.labels[5].labelMode = .text

        // Display mode fraction
        labels.append(createMathLabel("\\frac{x+\\frac{12}{5}}{y}+\\frac1z = \\frac{xz+y+\\frac{12}{5}z}{yz}", height:60))
        self.labels[6].backgroundColor = UIColor(hue:0.15, saturation:0.2, brightness:1.0, alpha:1.0)
        self.labels[6].contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0);
        
        // fraction in fraction in text mode
        labels.append(createMathLabel("\\frac{x+\\frac{12}{5}}{y}+\\frac1z = \\frac{xz+y+\\frac{12}{5}z}{yz}", height:60))
        self.labels[7].backgroundColor = UIColor(hue:0.15, saturation:0.2, brightness:1.0, alpha:1.0)
        self.labels[7].labelMode = .text
        
        // Exponents and subscripts
        // Large font
        labels.append(createMathLabel("\\frac{x^{2+3y}}{x^{2+4y}} = x^y \\times \\frac{z_1^{y+1}}{z_1^{y+1}}", height:90))
        self.labels[8].fontSize = 30;
        self.labels[8].textAlignment = .center

        // Small font
        labels.append(createMathLabel("\\frac{x^{2+3y}}{x^{2+4y}} = x^y \\times \\frac{z_1^{y+1}}{z_1^{y+1}}", height:30))
        self.labels[9].fontSize = 10;
        self.labels[9].textAlignment = .center

        // Square root
        labels.append(createMathLabel("5+\\sqrt{2}+3", height:40))

        // Square root inside square roots and with fractions
        labels.append(createMathLabel("\\sqrt{\\frac{\\sqrt{\\frac{1}{2}} + 3}{\\sqrt5^x}}+\\sqrt{3x}+x^{\\sqrt2}", height:90))

        // General root
        labels.append(createMathLabel("\\sqrt[3]{24} + 3\\sqrt{2}24", height:40))

        // Fractions and formulae in root
        labels.append(createMathLabel("\\sqrt[x+\\frac{3}{4}]{\\frac{2}{4}+1}", height:60))

        // Non-symbol operators with no limits
        labels.append(createMathLabel("\\sin^2(\\theta)=\\log_3^2(\\pi)", height:60))

        // Non-symbol operators with limits
        labels.append(createMathLabel("\\lim_{x\\to\\infty}\\frac{e^2}{1-x}=\\limsup_{\\sigma}5", height:60))

        // Symbol operators with limits
        labels.append(createMathLabel("\\sum_{n=1}^{\\infty}\\frac{1+n}{1-n}=\\bigcup_{A\\in\\Im}C\\cup B", height:60))

        // Symbol operators with limits text style
        labels.append(createMathLabel("\\sum_{n=1}^{\\infty}\\frac{1+n}{1-n}=\\bigcup_{A\\in\\Im}C\\cup B", height:60))
        self.labels[17].labelMode = .text

        // Non-symbol operators with limits text style
        labels.append(createMathLabel("\\lim_{x\\to\\infty}\\frac{e^2}{1-x}=\\limsup_{\\sigma}5", height:60))
        self.labels[18].labelMode = .text

        // Symbol operators with no limits
        labels.append(createMathLabel("\\int_{0}^{\\infty}e^x \\,dx=\\oint_0^{\\Delta}5\\Gamma", height:60))

        // Test italic correction for large ops
        labels.append(createMathLabel("\\int\\int\\int^{\\infty}\\int_0\\int^{\\infty}_0\\int", height:60))

        // Test italic correction for superscript/subscript
        labels.append(createMathLabel("U_3^2UY_3^2U_3Y^2f_1f^2ff", height:60))

        // Error
        labels.append(createMathLabel("\\notacommand", height:30))
        
        labels.append(createMathLabel("\\sqrt{1}", height:20))
        labels.append(createMathLabel("\\sqrt[|]{1}", height:20))
        labels.append(createMathLabel("{n \\choose k}", height:60))
        labels.append(createMathLabel("{n \\choose k}", height:30))
        self.labels[26].labelMode = .text
        labels.append(createMathLabel("\\left({n \\atop k}\\right)", height:40))
        labels.append(createMathLabel("\\left({n \\atop k}\\right)", height:30))
        self.labels[28].labelMode = .text
        labels.append(createMathLabel("\\underline{xyz}+\\overline{abc}", height:30))
        labels.append(createMathLabel("\\underline{\\frac12}+\\overline{\\frac34}", height:50))
        labels.append(createMathLabel("\\underline{x^\\overline{y}_\\overline{z}+5}", height:50))
        
        // spacing examples from the TeX book
        labels.append(createMathLabel("\\int\\!\\!\\!\\int_D dx\\,dy", height:50))
        // no spacing
        labels.append(createMathLabel("\\int\\int_D dxdy", height:50))
        labels.append(createMathLabel("y\\,dx-x\\,dy", height:30))
        labels.append(createMathLabel("y dx - x dy", height:30))
        
        // large spaces
        labels.append(createMathLabel("hello\\ from \\quad the \\qquad other\\ side", height:30))

        // Accents
        labels.append(createMathLabel("\\vec x \\; \\hat y \\; \\breve {x^2} \\; \\tilde x \\tilde x^2 x^2 ", height:30))
        labels.append(createMathLabel("\\hat{xyz} \\; \\widehat{xyz}\\; \\vec{2ab}", height:30))
        labels.append(createMathLabel("\\hat{\\frac12} \\; \\hat{\\sqrt 3}", height:50))

        // large roots
        labels.append( createMathLabel("\\colorbox{#f0f0e0}{\\sqrt{1+\\colorbox{#d0c0d0}{\\sqrt{1+\\colorbox{#a080c0}{\\sqrt{1+\\colorbox{#7050a0}{\\sqrt{1+\\colorbox{403060}{\\colorbox{#102000}{\\sqrt{1+\\cdots}}}}}}}}}}}", height:80))
        
        labels.append(createMathLabel("\\begin{bmatrix}" +
                               "a & b\\\\ c & d \\\\ e & f \\\\ g &  h \\\\ i & j" +
                               "\\end{bmatrix}", height:120))
        labels.append(createMathLabel("x{\\scriptstyle y}z", height:30))
        labels.append(createMathLabel("x \\mathrm x \\mathbf x \\mathcal X \\mathfrak x \\mathsf x \\bm x \\mathtt x \\mathit \\Lambda \\cal g", height:30))
        labels.append(createMathLabel("\\mathrm{using\\ mathrm}", height:30))
        labels.append(createMathLabel("\\text{using text}", height:30))
        labels.append(createMathLabel("\\text{Mary has }\\$500 + \\$200.", height:30))
        
        labels.append(createMathLabel("\\colorbox{#888888}{\\begin{pmatrix}\\colorbox{#ff0000}{a} & \\colorbox{#00ff00}{b} \\\\ \\colorbox{#00aaff}{c} &" + "\\colorbox{#f0f0f0}{d}\\end{pmatrix}}", height:70))
        
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

