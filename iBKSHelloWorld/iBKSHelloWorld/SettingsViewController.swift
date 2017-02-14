//
//  SettingsViewController.swift
//  iBKSHelloWorld
//
//  Created by Gabriel Codarcea on 8/2/17.
//  Copyright © 2017 Accent Advanced Systems SLU. All rights reserved.
//

import UIKit

protocol SettingsDelegate{
    func didSetNewSettings()
}

class SettingsViewController: UIViewController, UITextFieldDelegate {

    var delegate: SettingsDelegate?
    
    @IBOutlet var backBtn: UIImageView!
    
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet var uuidBox: UITextField!
    @IBOutlet var majorBox: UITextField!
    @IBOutlet var minorBox: UITextField!
    @IBOutlet var messageBox: UITextField!
    
    @IBOutlet var radio1: UIButton!
    @IBOutlet var radio2: UIButton!
    @IBOutlet var radio3: UIButton!
    
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    
    var selectedRange = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add back button tap gesture
        let backPressedGesture = UITapGestureRecognizer(target: self, action: #selector(self.backBtnPressed(_:)))
        self.backBtn.isUserInteractionEnabled = true
        self.backBtn.addGestureRecognizer(backPressedGesture)
        
        radio1.setImage(UIImage(named: "r_sel.png"), for: .selected)
        radio2.setImage(UIImage(named: "r_sel.png"), for: .selected)
        radio3.setImage(UIImage(named: "r_sel.png"), for: .selected)
        
        radio1.setImage(UIImage(named: "r_unsel.png"), for: UIControlState())
        radio2.setImage(UIImage(named: "r_unsel.png"), for: UIControlState())
        radio3.setImage(UIImage(named: "r_unsel.png"), for: UIControlState())
        
        widthConstraint.constant = self.view.frame.width / 3
        self.view.layoutIfNeeded()
        
        uuidBox.delegate = self
        majorBox.delegate = self
        minorBox.delegate = self
        messageBox.delegate = self
        
        uuidBox.addTarget(self, action: #selector(self.uuidDidChanged(tf:)), for: UIControlEvents.editingChanged)
        majorBox.addTarget(self, action: #selector(self.majminDidChanged(tf:)), for: UIControlEvents.editingChanged)
        minorBox.addTarget(self, action: #selector(self.majminDidChanged(tf:)), for: UIControlEvents.editingChanged)
        
        //Restore previously saved settings if there are any
        var mUuid = UserDefaults.standard.object(forKey: "mUuid")
        if(mUuid == nil){
            mUuid = "00000000000000000000000000000000"
        }
        uuidBox.text = mUuid as! String?
        
        var mMajor = UserDefaults.standard.object(forKey: "mMajor")
        if(mMajor == nil){
            mMajor = "0001"
        }
        majorBox.text = mMajor as! String?
        
        var mMinor = UserDefaults.standard.object(forKey: "mMinor")
        if(mMinor == nil){
            mMinor = "0001"
        }
        minorBox.text = mMinor as! String?
        
        var mMsg = UserDefaults.standard.object(forKey: "mMsg")
        if(mMsg == nil){
            mMsg = "This is a notification text example!"
        }
        messageBox.text = mMsg as! String?

        var mRange = UserDefaults.standard.integer(forKey: "mRange")
        if(mRange != 0 && mRange != 1 && mRange != 2){
            mRange = 0
        }
        selectRange(mRange)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    func uuidDidChanged(tf: UITextField) {
        if (tf.text!.characters.count > 32) {
            tf.deleteBackward()
        }
        if(tf.text!.isValidHexNumber() == false){
            tf.deleteBackward()
        }
    }
    
    func majminDidChanged(tf: UITextField) {
        if (tf.text!.characters.count > 4) {
            tf.deleteBackward()
        }
        if(tf.text!.isValidHexNumber() == false){
            tf.deleteBackward()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTage = textField.tag+1
        let nextResponder = textField.superview?.viewWithTag(nextTage) as UIResponder!
        
        if(nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        
        return false;
    }
    
    func selectRange(_ id: Int){
        radio1.isSelected = false
        radio2.isSelected = false
        radio3.isSelected = false
        
        switch id {
        case 0:
            radio1.isSelected = true
        case 1:
            radio2.isSelected = true
        case 2:
            radio3.isSelected = true
        default: break
            
        }
        
        selectedRange = id
    }
    
    @IBAction func radio1Pressed(_ sender: Any) {
        selectRange(0)
    }
    
    @IBAction func radio2Pressed(_ sender: Any) {
        selectRange(1)
    }
    
    @IBAction func radio3Pressed(_ sender: Any) {
        selectRange(2)
    }

    @IBAction func savePressed(_ sender: Any) {
        if(uuidBox.text?.characters.count != 32){
            showErrorDialog("UUID length must be 32 HEX characters long!")
            return
        }
        if(majorBox.text?.characters.count != 4){
            showErrorDialog("Major length must be 4 HEX characters long!")
            return
        }
        if(minorBox.text?.characters.count != 4){
            showErrorDialog("Minor length must be 4 HEX characters long!")
            return
        }
        if(messageBox.text?.characters.count == 0){
            showErrorDialog("Message can not be empty!")
            return
        }
        
        UserDefaults.standard.set(uuidBox.text!, forKey: "mUuid")
        UserDefaults.standard.set(majorBox.text!, forKey: "mMajor")
        UserDefaults.standard.set(minorBox.text!, forKey: "mMinor")
        UserDefaults.standard.set(selectedRange, forKey: "mRange")
        UserDefaults.standard.set(messageBox.text!, forKey: "mMsg")
        UserDefaults.standard.synchronize()
        
        //Save the data and call the callback method to let the ranging know settings have changed.
        delegate?.didSetNewSettings()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Dismiss view on back button pressed
    func backBtnPressed(_ sender:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    func showErrorDialog(_ msg: String){
        let dialog = UIAlertController(title: "Error!", message: msg, preferredStyle: .alert)
        
        dialog.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            //Dismiss dialog
        }))
        
        DispatchQueue.main.async {
            self.present(dialog, animated: true, completion: nil)
        }
    }
    
    
}

extension String {
    func isValidHexNumber() -> Bool {
        let hexCharacters = NSCharacterSet(charactersIn: "0123456789ABCDEF").inverted
        return !self.isEmpty && self.uppercased().rangeOfCharacter(from: hexCharacters) == nil
    }
}
